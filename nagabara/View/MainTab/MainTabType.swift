//
//  MainTabType.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation

enum MainTabType: CaseIterable {
    case home
    case ranking
    case profile
    
    var title: String {
        switch self {
        case .home:
            return "홈"
        case .ranking:
            return "랭킹"
        case .profile:
            return "프로필"
        }
    }
    
    var image: String {
        switch self {
        case .home:
            return "house.fill"
        case .ranking:
            return "flag.fill"
        case .profile:
            return "person.crop.circle.fill"
        }
    }
}
