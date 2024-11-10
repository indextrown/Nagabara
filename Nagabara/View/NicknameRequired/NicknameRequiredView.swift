//
//  NicknameRequiredView.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI

struct NicknameRequiredView: View {
    var body: some View {

        RectView(width: 200,
                 height: 200,
                 color: .hex("#888888"),
                 image: Image(systemName: "person.fill"),
                 imageColor: .white)
    }
}

#Preview {
    NicknameRequiredView()
}
