//
//  UserService.swift
//  nagabara
//
//  Created by 김동현 on 11/10/24.
//

import Foundation
import Combine

protocol UserServiceType {
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError>
    func getUser(userId: String) -> AnyPublisher<User, ServiceError>
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError>
    func updateUserNickname(userId: String, nickname: String) -> AnyPublisher<Void, ServiceError>
    func deleteUser(userId: String) -> AnyPublisher<Void, ServiceError>
}

class UserService: UserServiceType {
    // subscriptions는 Set<AnyCancellable> 타입의 프로퍼티
    // sink 구독 객체를 저장하여, ViewModel이나 다른 클래스가 해제될 때 구독도 자동으로 해제되도록 관리
    // sink와 같은 메서드를 호출하면 Combine에서 **퍼블리셔(Publisher)**와 구독자(Subscriber) 간의 연결이 만들어진다
    // 이 연결을 AnyCancellable 객체로 반환
    // 구독이 살아 있는 동안 퍼블리셔는 계속 데이터를 전송하고, 구독자가 이를 처리
    private var subscriptions = Set<AnyCancellable>()
    private var dbRepository: UserDBRepositoryType
    
    init(dbRepository: UserDBRepositoryType) {
        self.dbRepository = dbRepository
    }
    
    func addUser(_ user: User) -> AnyPublisher<User, ServiceError> {
        dbRepository.addUser(user.toObject())
            .map { user }
            .mapError { .error($0) }
            .eraseToAnyPublisher()
    }
    
    func getUser(userId: String) -> AnyPublisher<User, ServiceError> {
        dbRepository.getUser(userId: userId)
            .map { $0.toModel() }
            .mapError { dbError in
                if case .emptyValue = dbError {
                    return .userNotFound
                } else {
                    return .error(dbError)
                }
            }
            .eraseToAnyPublisher()
    }
    
    func loadUsers(id: String) -> AnyPublisher<[User], ServiceError> {
        Empty().eraseToAnyPublisher()
    }
    
    func updateUserNickname(userId: String, nickname: String) -> AnyPublisher<Void, ServiceError> {
        let updatedUserObject = UserObject(id: userId, name: "", nickname: nickname) // 필요한 다른 속성도 추가
            return dbRepository.updateUser(updatedUserObject)
                .mapError { .error($0) }
                .eraseToAnyPublisher()
    }
    
    func deleteUser(userId: String) -> AnyPublisher<Void, ServiceError> {
        Future { promise in
            // 데이터베이스에서 사용자 삭제 로직
            self.dbRepository.deleteUser(userId: userId) // dbRepository를 사용하여 삭제
                .sink { completion in
                    if case .failure(let error) = completion {
                        promise(.failure(.error(error)))
                    }
                } receiveValue: {
                    promise(.success(()))
                }
                .store(in: &self.subscriptions) // subscriptions에 저장
        }
        .eraseToAnyPublisher()
    }
}
