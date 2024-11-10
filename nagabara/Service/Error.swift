//
//  ServiceError.swift
//  nagabara
//
//  Created by 김동현 on 11/10/24.
//

import Foundation

// MARK: - ServiceError
enum ServiceError: Error {
    case error(Error)
    case userNotFound
}

extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .error(let dbError):
                return dbError.localizedDescription
            case .userNotFound:
                return "사용자를 찾을 수 없습니다."
        }
    }
}

// MARK: - AuthenticationError
enum AuthenticationError: Error {
    case clientIDError
    case tokenError
    case invalidated
}

// MARK: - DBError
enum DBError: Error {
    case error(Error)
    case emptyValue
    case invalidatedType
    case userNotFound
}

extension DBError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .error(let error):
            return "오류가 발생했습니다. : \(error.localizedDescription)"
        case .emptyValue:
            return "데이터베이스에 해당 사용자 정보가 없습니다."
        case .invalidatedType:
            return "유효하지 않은 데이터 타입입니다."
        case .userNotFound:
            return "사용자를 찾을 수 없습니다."
        }
    }
}
