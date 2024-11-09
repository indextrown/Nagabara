//
//  LoginView.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI
import AuthenticationServices

// MARK: - View
struct LoginView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    var body: some View {
        VStack {

            // apple login
            SignInWithAppleButton { request in
                
            } onCompletion: { request in
                print("1")
            }
            .frame(height: 50)
            .padding(.horizontal, 15)
            
            // google login
            Button {
                authVM.authenticationState = .authenticated
            } label: {
                HStack {
                    Image("Google")
                        .resizable()                    // 이미지 크기 조절 가능
                        .aspectRatio(contentMode: .fit) // 비율 유지하며 크기 조정
                        .frame(width: 24, height: 24)   // 크기 설정
                    Text("Google 로그인")
                }
            }
            .buttonStyle(SocialLoginButton(buttonType: "Google"))
        }
        .padding()
    }
}

#Preview {
    LoginView()
}
