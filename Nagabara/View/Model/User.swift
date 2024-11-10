//
//  User.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation

enum Gender: String, Codable {
    case male = "남자"
    case female = "여자"
    case unspecified = "선택안함"
}

struct User {
    var id: String                // UID
    var name: String              // 소셜 이름
    var phoneNumber: String?      // 전화번호
    var profileURL: String?       // 프로필URL
    var nickname: String?         // 닉네임
    var birthday: Date?           // 생일
    var profileImageURL: String?  // 프로필 이미지
    var gender: Gender?
    
}

extension User {
    func toObject() -> UserObject {
        .init(id: id,
              name: name,
              phoneNumber: phoneNumber,
              profileURL: profileURL,
              nickname: nickname,
              birthday: birthday,
              profileImageURL: profileImageURL,
              gender: gender
              
        )
    }
}


