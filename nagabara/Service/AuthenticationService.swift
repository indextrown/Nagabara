//
//  AuthenticationService.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation
import Combine
import AuthenticationServices
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

protocol AuthenticationServiceType {
    // 구글 로그인
    func signInWithGoogle() -> AnyPublisher<User, ServiceError>
    
    // 애플 로그인
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<User, ServiceError>
    
    // 로그인 확인
    func checkAuthenticationState() -> String?
    
    // 로그아웃
    func logout() -> AnyPublisher<Void, ServiceError>
}
/*
 MARK: - <성공시 반환, 실패시 반환>
 AnyPublisher는 Combine의 퍼블리셔로, ViewModel이나 다른 클래스에서 결과를 구독(Subscribe)할 수 있다
 */


/* 
 MARK: - Future를 사용한 비동기 작업 처리
 Future는 Combine에서 제공되는 퍼블리셔로, 한 번의 비동기 작업을 처리한 뒤 완료,실패하는 퍼블리셔이다
 Future는 클로저 형태로 작성되며, 이 클로저 안에 비동기 작업이 이루어진다
 비동기 작업이 끝나면 promise를 호출하여 결과를 전달한다
 */
 
class AuthenticationService: AuthenticationServiceType {
    func signInWithGoogle() -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.signInWithGoogle{ result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) -> String {
        request.requestedScopes = [.fullName, .email]
        
        // nonce 세팅할건데 nonce는 랜덤스트림을 만들오소 sha암호화를 이용해 만들 것이다
        let nonce = randomNonceString()
        request.nonce = sha256(nonce)
        return nonce
    }
    
    // 애플로그인도 combine지원하지 않아서 completion handler만들어서 future로 publisher를 만들자
    func handleSignInWithAppleCompletion(_ authorization: ASAuthorization, none: String) -> AnyPublisher<User, ServiceError> {
        Future { [weak self] promise in
            self?.handleSignInWithAppleCompletion(authorization, nonce: none) { result in
                switch result {
                case let .success(user):
                    promise(.success(user))
                case let .failure(error):
                    promise(.failure(.error(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    // 로그인 확인
    func checkAuthenticationState() -> String? {
        if let user = Auth.auth().currentUser {
            return user.uid
        } else {
            return nil
        }
    }
    
    // 로그아웃
    func logout() -> AnyPublisher<Void, ServiceError> {
        Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(.error(error)))
            }
        }.eraseToAnyPublisher()
    }
}

// 실제 비동기 작업 수행하는 함수들
extension AuthenticationService {
    
    private func signInWithGoogle(completion: @escaping (Result<User, Error>) -> Void) {
        
        // MARK: - firebase clientId 가져오기
        // GoogleService-Info.plist 파일에 포함된 clientID를 가져온다
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(AuthenticationError.clientIDError)) // 실패
            return
        }
        
        // Google Sign-in SDK에 클라이언트ID 설정 및 초기화
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // 실제 로그인 프로세스(구글로그인 창이 뜰 뷰를 가져옴-> 윈도우에서 rootview를 추출하여 보내주자
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            return
        }
        
        // 로그인 진행(완료시 컨프리션 호출됨)
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            // 성공: result?.user와 idToken 가져온다
            // 실패: 오류를 반환하거나 유효한 사용자 정보가 없으면 실패 처리
            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                // 유저정보, 토큰정보가 없다면
                completion(.failure(AuthenticationError.tokenError))
                return
            }
            
            // 로그인 성공 후 Firebase 인증에 필요한 자격증명(credential)을 생성
            let accessToken = user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            // TODO: -
            self?.authenticateUserWithFirebase(credential: credential, completion: completion)
        }
    }
    
    private func handleSignInWithAppleCompletion(_ authorization: ASAuthorization,
                                                 nonce: String,
                                                 completion: @escaping (Result<User, Error>) -> Void) {
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let appleIDToken = appleIDCredential.identityToken else {
                print("애플 로그인 실패: 유효하지 않은 자격 증명")
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("애플 로그인 실패: ID 토큰 변환 실패") // 에러 출력 추가
            completion(.failure(AuthenticationError.tokenError))
            return
        }
        
        let credential = OAuthProvider.credential(providerID: AuthProviderID.apple,
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
                                          
        
        authenticateUserWithFirebase(credential: credential) { result in
            switch result {
            case var .success(user):
                user.name = [appleIDCredential.fullName?.givenName, appleIDCredential.fullName?.familyName]
                    .compactMap{ $0 }
                    .joined(separator: " ")
                completion(.success(user))
            case let .failure(error):
             print("Firebase 인증 실패: \(error.localizedDescription)") // 에러 출력 추가
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - 파이어베이스 인증 진행 함수
    private func authenticateUserWithFirebase(credential: AuthCredential, completion: @escaping (Result<User, Error>) -> Void ) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let result else {
                completion(.failure(AuthenticationError.invalidated))
                return
            }
            
            // MARK: - nickname, birthday는 회원가입시 입력 예정
            let firebaseUser = result.user
            let user: User = .init(id: firebaseUser.uid,
                                   name: firebaseUser.displayName ?? "",
                                   phoneNumber: firebaseUser.phoneNumber,
                                   profileURL: firebaseUser.photoURL?.absoluteString)
            
            completion(.success(user))
            
        }
    }
}
