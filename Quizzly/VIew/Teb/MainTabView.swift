//
//  MainTabView.swift
//  Quizzly
//
//  Created by 강민지 on 5/15/25.
//


//
//  Tab.swift
//  Quizzly
//
//  Created by 강민지 on 5/15/25.
//

import SwiftUI

struct MainTabView: View {
    let profile: Profile
    @Binding var navigationPath: NavigationPath
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var homeViewModel: HomeViewModel
    var userID:String
    
    var body: some View {
        TabView {
            HomeView(profile: profile, navigationPath: $navigationPath)
            HomeView(profile: profile, navigationPath: $navigationPath,userID:userID)
                .environmentObject(homeViewModel)
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            
            AddQuizView()
                .tabItem {
                    Label("퀴즈 생성", systemImage: "plus.circle")
                }
            
            DashboardView()
                .tabItem {
                    Label("대시보드", systemImage: "chart.bar.xaxis")
                }
        }
    }
}

#Preview {
    MainTabView(
        profile: Profile(name: "민지", createdAt: .now),
        navigationPath: .constant(NavigationPath())
    )
}
