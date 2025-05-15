//
//  MainTabView.swift
//  Quizzly
//
//  Created by 강민지 on 5/15/25.
//

import SwiftUI
import SwiftData // ModelContainer를 사용하기 위해 필요할 수 있음

struct MainTabView: View {
    let profile: Profile // Profile은 계속 필요
    @Binding var navigationPath: NavigationPath
    
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var quizViewModel: QuizViewModel // QuizViewModel 주입

    var body: some View {
        TabView {
            HomeView(profile: profile, navigationPath: $navigationPath)
                // HomeView에서 CategoryViewModel을 사용하므로 이미 주입되어 있어야 합니다.
                // HomeView에서 QuizViewModel도 필요하다면 여기서 주입하거나,
                // HomeView 내부에서 @EnvironmentObject로 받을 수 있습니다.
                // .environmentObject(quizViewModel) // HomeView에서 직접 필요하다면 전달
                .tabItem {
                    Label("홈", systemImage: "house")
                }
            
            // AddQuizView가 ViewModel을 사용하도록 수정
            AddQuizView()
                .environmentObject(quizViewModel) // AddQuizView에 QuizViewModel 주입
                .environmentObject(categoryViewModel) // CategoryViewModel도 주입 (AddQuizView 내부에서 사용)
                .tabItem {
                    Label("퀴즈 생성", systemImage: "plus.circle")
                }
            
            DashboardView()
                // DashboardView에서 최근 퀴즈 목록 등을 보여주려면 QuizViewModel 필요 가능성 있음
                // .environmentObject(quizViewModel) // DashboardView에서 직접 필요하다면 전달
                .tabItem {
                    Label("대시보드", systemImage: "chart.bar.xaxis")
                }
        }
        // MainTabView 자체가 ViewModel을 상위 뷰(예: ChooseProfileView)로부터
        // @EnvironmentObject로 받고 있으므로, 여기서 별도로 주입할 필요는 없습니다.
        // 상위 뷰에서 .environmentObject(quizViewModel) 등이 호출되어야 합니다.
    }
}

#Preview {
    // Preview를 위한 설정
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    // ModelContainer는 Profile, QuizCategory, Quiz 타입을 알아야 합니다.
    let container = try! ModelContainer(for: Profile.self, QuizCategory.self, Quiz.self, configurations: config)
    
    // modelContext는 container에서 가져옵니다.
    let modelContext = container.mainContext

    // 샘플 프로필 생성 및 삽입
    let sampleProfile = Profile(name: "민지", createdAt: .now)
    modelContext.insert(sampleProfile)
    
    // ViewModel 인스턴스 생성
    let categoryVM = CategoryViewModel(modelContext: modelContext)
    let quizVM = QuizViewModel(modelContext: modelContext)
    
    // categoryVM에 샘플 데이터 추가 (필요한 경우)
    // let sampleCategory = QuizCategory(name: "Sample Preview Category")
    // modelContext.insert(sampleCategory)
    // categoryVM.fetchCategory() // Preview에서 카테고리 목록을 사용한다면 로드

    // return 키워드 제거
    return MainTabView( // Explicit return removed here
        profile: sampleProfile,
        navigationPath: .constant(NavigationPath())
    )
    .modelContainer(container)
    .environmentObject(categoryVM)
    .environmentObject(quizVM)
}
