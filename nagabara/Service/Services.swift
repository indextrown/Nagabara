//
//  Services.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import Foundation

protocol ServiceType {
    var authService: AuthenticationServiceType { get set}
}

class Services: ServiceType {
    var authService: AuthenticationServiceType
    
    init() {
        self.authService = AuthenticationService()
    }
}
