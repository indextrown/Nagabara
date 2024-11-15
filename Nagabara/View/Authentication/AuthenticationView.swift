//
//  AuthenticationView.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject var authVM: AuthenticationViewModel
    var body: some View {
        VStack {
            switch authVM.authenticationState {
                case .unauthenticated:
                    LoginView()
                        .environmentObject(authVM)
                case .authenticated:
                    MainTabView()
                        .environmentObject(authVM)
                case .nicknameRequired:
                    NicknameRequiredView()
                        .environmentObject(authVM)
            }
        }
        .onAppear {
            authVM.send(action: .checkAuthenticationState)
        }
    }
}

#Preview {
    AuthenticationView(authVM: AuthenticationViewModel(container: DIContainer(services: Services())))
}
