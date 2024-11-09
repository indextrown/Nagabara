//
//  ProfileView.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    
    var body: some View {
        VStack {
            Button {
                authVM.authenticationState = .unauthenticated
            } label: {
                Text("로그아웃")
                    .foregroundColor(.black)
                    .padding() // 버튼 내부 여백 추가
                    .frame(maxWidth: .infinity) // 버튼 넓이 설정
            }
            .background(.white) // 버튼 배경색 설정
            .overlay(
                RoundedRectangle(cornerRadius: 10) // 둥근 테두리 모양
                    .stroke(Color.black, lineWidth: 2) // 테두리 색상과 두께 설정
            )
            .clipShape(RoundedRectangle(cornerRadius: 10)) // 둥근 모양 적용
            .padding() // 버튼 외부 여백 추가
        }
    }
}

#Preview {
    ProfileView()
}
