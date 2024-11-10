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
    case nicknamerequired
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
                    self?.authenticationState = .authenticated
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
                        self?.authenticationState = .authenticated
                        //self?.send(action: .checkNickname(user.id))
                    }.store(in: &subscriptions)
            } else if case let .failure(error) = result {
                isLoading = false
                print(error.localizedDescription)
            }
            
        case .checkAuthenticationState:
            if let userId = container.services.authService.checkAuthenticationState() {
                self.userId = userId
                self.authenticationState = .authenticated // 사용자 ID가 있으면 인증 상태 변경
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
            
        case .checkNickname:
            print()
            
        case .deleteAccount:
            print()
        }
    }
}
