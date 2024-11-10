//
//  DIContainer.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation

class DIContainer: ObservableObject {
    var services: ServiceType
    
    init(services: ServiceType) {
        self.services = services
    }
}
