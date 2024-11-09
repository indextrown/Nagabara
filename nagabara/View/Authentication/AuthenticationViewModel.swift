//
//  AuthenticationViewModel.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation
import AuthenticationServices

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
        case updateNickname
        case checkNickname
        case deleteAccount
    }
    
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var isLoading = false
    @Published var currentUser: User?
    
    
    private var currentNonce: String?
    private var container: DIContainer
    
    init(container: DIContainer) {
        self.container = container
    }
}
