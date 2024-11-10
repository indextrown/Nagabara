//
//  AuthenticationViewModel.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation
import AuthenticationServices
import Combine
import FirebaseAuth

enum AuthenticationState {
    case unauthenticated
    case authenticated
    case nicknameRequired
}

class AuthenticationViewModel: ObservableObject {
    enum Action {
        case googleLogin
        case appleLogin(ASAuthorizationRequest)
        case appleLoginCompletion(Result<ASAuthorization, Error>)
        case checkAuthenticationState
        case logout
        case updateNickname(String)
        case checkNickname(String)
        case deleteAccount
    }
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isLoading = false
    @Published var currentUser: User?
    
    private var currentNonce: String?
    private var container: DIContainer
    private var subscriptions = Set<AnyCancellable>()
    private var userId: String?
    
    init(container: DIContainer) {
        self.container = container
    }
    
    func send(action: Action) {
        switch action {
            
        case .googleLogin:
            isLoading = true
            // MARK: - 구글 로그인 완료가 되면
            container.services.authService.signInWithGoogle()
                // TODO: - db추가
                .flatMap{ user in
                    self.container.services.userService.getUser(userId: user.id)
                        .catch { error -> AnyPublisher<User, ServiceError> in
                            // 에러 발생하면 유저를 추가
                            return self.container.services.userService.addUser(user)
                        }
                }
                // MARK: - 실패시
                .sink { [weak self] completion in
                    // TODO: - 실패시
                    if case .failure = completion {
                        self?.isLoading = false
                    }
                // MARK: - 성공시
                } receiveValue: { [weak self] user in
                    self?.isLoading = false
                    self?.userId = user.id // 유저정보가 오면 뷰모델에서 아이디 보유하도록
                    self?.send(action: .checkNickname(user.id))
                    //self?.authenticationState = .authenticated
                }.store(in: &subscriptions) // sink를 하면 subscriptions가 리턴된다 -> 뷰모델에서 관리
                                            //subscriptions은 뷰모델에서 관리할건데 뷰모델에서 구독이 여러개 있을 수 있어서 set으로 관리하자
        case let .appleLogin(request):
            let nonce = container.services.authService.handleSignInWithAppleRequest(request as! ASAuthorizationAppleIDRequest)
            currentNonce = nonce
            
        case let .appleLoginCompletion(result):
            if case let .success(authorization) = result {
                guard let nonce = currentNonce else { return }
                
                container.services.authService.handleSignInWithAppleCompletion(authorization, none: nonce)
                    // TODO: - db추가
                    .flatMap { user in
                        // 사용자가 존재하는지 확인 후, 없으면 addUser 호출
                        self.container.services.userService.getUser(userId: user.id)
                            .catch { error -> AnyPublisher<User, ServiceError> in
                                // 에러 발생하면 유저를 추가
                                return self.container.services.userService.addUser(user)
                            }
                    }
                    .sink { [weak self] completion in
                        // TODO: - 실패시
                        if case .failure = completion {
                            self?.isLoading = false
                        }
                    } receiveValue: { [weak self] user in
                        self?.isLoading = false
                        self?.userId = user.id
                        self?.send(action: .checkNickname(user.id))
                        //self?.authenticationState = .authenticated
                    }.store(in: &subscriptions)
            } else if case let .failure(error) = result {
                isLoading = false
                print(error.localizedDescription)
            }
            
        case .checkAuthenticationState:
            if let userId = container.services.authService.checkAuthenticationState() {
                self.userId = userId
                self.authenticationState = .authenticated // 사용자 ID가 있으면 인증 상태 변경
                self.send(action: .checkNickname(userId)) // 해도되고 안해도되고
            }
            
        case .logout:
            container.services.authService.logout()
                .sink { completion in
                    
                } receiveValue: { [weak self] _ in
                    self?.authenticationState = .unauthenticated
                    //self?.userId = nil
                }.store(in: &subscriptions)
            
        case .updateNickname:
            print()
            
        case .checkNickname(let userId):
            container.services.userService.getUser(userId: userId)
                .sink { completion in
                    if case .failure = completion {

                        self.authenticationState = .nicknameRequired
                    }
                } receiveValue: { existingUser in
                    if existingUser.nickname?.trimmingCharacters(in: .whitespaces).isEmpty ?? true {
                        // 닉네임이 비어있거나 nil입니다
                        self.authenticationState = .nicknameRequired
                    } else {
                        self.authenticationState = .authenticated
                    }
                }
                .store(in: &subscriptions)
            
        case .deleteAccount:
            guard let userId = self.userId else { return }
            
            // 1단계: Realtime Database에서 유저 데이터를 삭제
            container.services.userService.deleteUser(userId: userId)
                .tryMap { _ -> FirebaseAuth.User in
                    // 2단계: Firebase Auth 계정 삭제
                    guard let currentUser = Auth.auth().currentUser else {
                        throw ServiceError.userNotFound
                    }
                    return currentUser
                }
                .flatMap { currentUser -> AnyPublisher<Void, Error> in
                    return Future<Void, Error> { promise in
                        currentUser.delete { error in
                            if let error = error {
                                promise(.failure(error))
                            } else {
                                promise(.success(()))
                            }
                        }
                    }.eraseToAnyPublisher()
                }
                .sink { completion in
                    if case .failure(let error) = completion {
                        print("계정 삭제 실패: \(error)")
                    }
                } receiveValue: { [weak self] _ in
                    // 계정과 데이터가 성공적으로 삭제된 경우
                    self?.authenticationState = .unauthenticated
                    self?.userId = nil
                }
                .store(in: &subscriptions)
        }
    }
}
