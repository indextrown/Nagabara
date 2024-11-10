//
//  Color+Extension.swift
//  Nagabara
//
//  Created by 김동현 on 11/11/24.
//

import SwiftUI

extension Color {
    /// RGB 값을 기반으로 Color 생성
    /// - Parameters:
    ///   - red: Red 값 (0~255)
    ///   - green: Green 값 (0~255)
    ///   - blue: Blue 값 (0~255)
    ///   - opacity: 불투명도 (0.0~1.0)
    static func rgb(_ red: Double, _ green: Double, _ blue: Double, opacity: Double = 1.0) -> Color {
        return Color(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            opacity: opacity
        )
    }
    
    /// 16진수 색상 코드로 Color 생성
    /// - Parameters:
    ///   - hex: 16진수 색상 코드 (예: `#888888` 또는 `888888`)
    ///   - opacity: 불투명도 (0.0~1.0)
    static func hex(_ hex: String, opacity: Double = 1.0) -> Color {
        // '#' 제거
        let cleanedHex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        // 문자열을 Int로 변환
        guard let hexValue = Int(cleanedHex, radix: 16) else {
            return Color.clear // 변환 실패 시 투명한 색상 반환
        }
        
        // Red, Green, Blue 값 계산
        let red = Double((hexValue >> 16) & 0xFF)
        let green = Double((hexValue >> 8) & 0xFF)
        let blue = Double(hexValue & 0xFF)
        
        return Color(
            red: red / 255.0,
            green: green / 255.0,
            blue: blue / 255.0,
            opacity: opacity
        )
    }
}


// MARK: - 사용 예시
/*
 
 struct ContentView: View {
     var body: some View {
         VStack {
             Text("Custom RGB Color")
                 .font(.largeTitle)
                 .foregroundColor(.rgb(255, 100, 100)) // 밝은 빨간색

             RoundedRectangle(cornerRadius: 10)
                 .fill(Color.rgb(100, 200, 150, opacity: 0.8)) // 연한 녹색
                 .frame(width: 200, height: 100)
         }
         .padding()
     }
 }

 */
