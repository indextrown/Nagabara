//
//  Rect.swift
//  Nagabara
//
//  Created by 김동현 on 11/11/24.
//

import Foundation
import SwiftUI

struct RectView: View {
    var width: CGFloat = 100
    var height: CGFloat = 100
    var color: Color = .blue
    var radius: CGFloat = 20
    var image: Image?
    var imageColor: Color = .blue
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(color)
                .frame(width: width, height: height)
                .cornerRadius(radius)
               
            
            // 이미지가 존재하면
            if let image = image {
                image
                    .resizable()    // 크기 조절 가능
                    .scaledToFit()  // 프레임맞게 조절하되 원본 비율 유지
                    .frame(width: width-60, height: height-60)
                    .clipShape(RoundedRectangle(cornerRadius: radius)) // 이미지를 둥근 사각형 모양으로 자름
                    .foregroundColor(imageColor)
            }
        }
    }
}

struct RectView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // 단색 사각형
            RectView(width: 150, height: 100, color: .blue, radius: 15)
            
            // 이미지 포함 사각형 (예시용 시스템 이미지)
            RectView(width: 150, height: 100, color: .clear, radius: 15, image: Image(systemName: "photo"))
            
            // 커스텀 색상과 이미지
            RectView(width: 200, height: 150, color: .yellow, radius: 25, image: Image("exampleImage"))
        }
        .padding()
        .previewLayout(.sizeThatFits) // 컨테이너 크기 맞춤
    }
}
