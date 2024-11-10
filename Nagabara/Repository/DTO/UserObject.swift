//
//  UserObject.swift
//  nagabara
//
//  Created by 김동현 on 11/10/24.
//

import Foundation

struct UserObject: Codable {      // UserDBRepository에서 JSONEncoder().encode($0)를 위함
    var id: String                // UID
    var name: String              // 소셜 이름
    var phoneNumber: String?      // 전화번호
    var profileURL: String?       // 프로필URL
    var nickname: String?         // 닉네임
    var birthday: Date?           // 생일
    var profileImageURL: String?  // 프로필사진
    var gender: Gender?           // 성별 추가
}

extension UserObject {
    func toModel() -> User {
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
