//
//  nagabaraApp.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI

@main
struct NagabaraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var body: some Scene {
        WindowGroup {
            let container = DIContainer(services: Services())
            AuthenticationView(authVM: .init(container: container))
                //.environmentObject(container)
        }
    }
}
