//
//  User.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation

struct User {
    var id: String              // UID
    var name: String            // 소셜 이름
    var phoneNumber: String?    // 전화번호
    var profileURL: String?     // 프로필URL
    var nickname: String?       // 닉네임
    var birthday: Date?         // 생일
}

extension User {
    func toObject() -> UserObject {
        .init(id: id,
              name: name,
              phoneNumber: phoneNumber,
              profileURL: profileURL,
              nickname: nickname,
              birthday: birthday
        )
    }
}


