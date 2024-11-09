//
//  MainTabView.swift
//  nagabara
//
//  Created by 김동현 on 11/9/24.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authVM: AuthenticationViewModel
    @EnvironmentObject var container: DIContainer
    @State private var selectedTab: MainTabType = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForEach(MainTabType.allCases, id: \.self) {tab in // CaseIterable
                Group {
                    switch tab {
                    case .home:
                        Homeview()
                    case .ranking:
                        RankingView()
                    case .profile:
                        ProfileView()
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.image)
                }
            }
        }
        .tint(Color.black)
    }
}

#Preview {
    MainTabView()
}
    
