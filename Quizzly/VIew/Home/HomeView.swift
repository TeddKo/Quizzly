//
//  HomeView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

// MARK: ProfileInfoView
struct ProfileInfoView: View {
    let name: String
    let themeColorHex: String?
    
    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(themeColorHex?.asHexColor ?? .gray)
                .frame(width: 45, height: 45)
                .overlay {
                    Text(name.prefix(1))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("\(name)님, 안녕하세요!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text("학습 계속해보세요")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            Spacer()
        }
    }
}

// MARK: TotalCorrectRateView
struct TotalCorrectRateView: View {
    // TODO: 실제 정답률 데이터로 교체
    let overallCorrectRate: Double = 0.78 // 예시 값
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("전체 정답률")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
                
                Text("\(Int(overallCorrectRate * 100))%")
                    .font(.title3)
                    .bold()
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 10)
                    .frame(width: 55, height: 55)
                
                Circle()
                    .rotation(.degrees(-90))
                    .trim(from: 0, to: CGFloat(overallCorrectRate))
                    .stroke(.blue, style: .init(lineWidth: 10, lineCap: .round))
                    .frame(width: 55, height: 55)
            }
            .clipShape(.circle)
        }
        .padding(13)
        .background(.blue.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.blue.opacity(0.05), lineWidth: 1)
        )
        .cornerRadius(8)
    }
}

// MARK: RecommendedQuizView
struct RecommendedQuizView: View {
    // TODO: 실제 추천 퀴즈 데이터로 교체
    var body: some View {
        VStack(alignment: .leading) {
            Text("추천 퀴즈")
                .font(.headline)
                .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("알고리즘 기초 퀴즈")
                        .fontWeight(.semibold)
                    
                    Text("취약점 보완 추천")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(.black.opacity(0.5))
                }
                
                Spacer()
                
                Button {
                    // TODO: 추천 퀴즈 시작 액션
                } label: {
                    Text("시작")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.8))
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(13)
            .background(.yellow.opacity(0.09))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.orange.opacity(0.1), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

// MARK: CategorySectionView
struct CategorySectionView: View {
    @Binding var showingAllCategories: Bool
    let categories: [QuizCategory]
    @EnvironmentObject var categoryViewModel: CategoryViewModel

    @State private var showingAddCategorySheet = false
    
    @State private var editingCategoryID: UUID? = nil

    @State private var categoryToDelete: QuizCategory? = nil
    @State private var showDeleteConfirmationAlert = false

    var gridColumns: [GridItem] {
            if categories.isEmpty {
                // 카테고리가 없으면 "카테고리 추가" 버튼이 전체 너비를 차지하도록 단일 컬럼을 사용합니다.
                return [GridItem(.flexible())]
            } else {
                // 카테고리가 있으면 기본 2열 레이아웃을 사용합니다.
                return [GridItem(.flexible()), GridItem(.flexible())]
            }
        }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("카테고리")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    if editingCategoryID != nil {
                        withAnimation {
                            editingCategoryID = nil
                        }
                    }
                    withAnimation {
                        showingAllCategories.toggle()
                    }
                } label: {
                    Text(showingAllCategories ? "간단히 보기" : "모두 보기")
                        .font(.footnote)
                }
            }
            .padding(.bottom, 10)
            
            LazyVGrid(columns: gridColumns, spacing: 12) {
                Button {
                    if editingCategoryID != nil {
                        withAnimation {
                            editingCategoryID = nil
                        }
                    }
                    showingAddCategorySheet = true
                } label: {
                    VStack {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.accentColor)
                        Text("카테고리 추가")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                    }
                    .padding(15)
                    .frame(maxWidth: .infinity, minHeight: 80)
                    .background(Color.gray.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.05), lineWidth: 2)
                    )
                    .cornerRadius(8)
                }

                let displayedCategories = showingAllCategories ? categories : Array(categories.prefix(3))
                
                if displayedCategories.isEmpty {
                    Caution()
                } else {
                    ForEach(displayedCategories) { category in
                        CategoryCardView(category: category)
                            .onLongPressGesture(minimumDuration: 0.5) {
                                withAnimation(.spring()) {
                                    self.editingCategoryID = category.id
                                }
                            }
                            .overlay(alignment: .topTrailing) {
                                if editingCategoryID == category.id {
                                    Button {
                                        self.categoryToDelete = category
                                        self.showDeleteConfirmationAlert = true
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title2)
                                            .foregroundColor(.red)
                                            .background(Circle().fill(Color.white.opacity(0.8)))
                                            .padding(3)
                                    }
                                    .offset(x: 8, y: -8)
                                    .transition(.scale.combined(with: .opacity))
                                    .zIndex(1)
                                }
                            }
                            .onTapGesture {
                                if editingCategoryID == category.id {
                                } else if editingCategoryID != nil {
                                    withAnimation {
                                        editingCategoryID = nil
                                    }
                                }
                            }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if editingCategoryID != nil {
                    withAnimation {
                        editingCategoryID = nil
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddCategorySheet) {
            AddCategoryView()
                .environmentObject(categoryViewModel)
        }
        .alert("카테고리 삭제", isPresented: $showDeleteConfirmationAlert, presenting: categoryToDelete) { categoryToDeletePresnting in
            Button("삭제", role: .destructive) {
                categoryViewModel.deleteCategory(categoryToDeletePresnting)
                editingCategoryID = nil
            }
            Button("취소", role: .cancel) {
                editingCategoryID = nil
            }
        } message: { categoryToDeletePresnting in
            Text("\(categoryToDeletePresnting.name) 카테고리를 삭제하시겠습니까?\n퀴즈도 모두 삭제됩니다.")
        }
    }
}

// MARK: CategoryCardView
struct CategoryCardView: View {
    let category: QuizCategory
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(category.name)
                    .font(.subheadline)
                    .bold()
                
                Text("문제 \(category.quizzes?.count ?? 0)개")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: category.iconName ?? "folder.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(category.themeColorHex?.asHexColor ?? .gray)
                .padding(8)
        }
        .padding(15)
        .frame(maxWidth: .infinity, minHeight: 80)
        .background((category.themeColorHex?.asHexColor ?? .gray).opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke((category.themeColorHex?.asHexColor ?? .gray).opacity(0.05), lineWidth: 2)
        )
        .cornerRadius(8)
    }
}



// MARK: RecentQuizSectionView
struct RecentQuizSectionView: View {
    let quizAttempts: [QuizAttempt]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("최근 학습")
                .font(.headline)
                .padding(.bottom, 10)
            
            if quizAttempts.isEmpty {
                Text("최근 학습 기록이 없습니다.")
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                ForEach(quizAttempts.indices, id: \.self) { index in
                    let attempt = quizAttempts[index]
                    
                    RecentQuizCardView(attempt: attempt)
                    
                    if index < quizAttempts.count - 1 {
                        Divider()
                    }
                }
            }
        }
    }
}

// MARK: RecentQuizCardView
struct RecentQuizCardView: View, Identifiable, Hashable {
    let id = UUID()
    let attempt: QuizAttempt
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: attempt.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(attempt.wasCorrect ? .green : .red)
                .padding(8)
                .background((attempt.wasCorrect ? Color.green : Color.red).opacity(0.1))
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(attempt.quiz?.questionDescription ?? "알 수 없는 질문")
                    .font(.subheadline)
                    .bold()
                    .lineLimit(1)
                
                Text("\(attempt.attemptDate, style: .date) \(attempt.attemptDate, style: .time)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            Spacer()
        }
    }
}


// MARK: HomeView
struct HomeView: View {
    @Bindable var profile: Profile
    @Binding var navigationPath: NavigationPath
    
    @State private var showingAllCategories = false
    @EnvironmentObject private var categoryViewModel: CategoryViewModel
    @AppStorage("currentUserUUID") var id = ""
    var userID:String
    
    private func sectionBackground<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding()
            .background(.white)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                
                sectionBackground {
                    VStack(alignment: .leading, spacing: 15) {
                        ProfileInfoView(name: profile.name, themeColorHex: profile.themeColorHex)
                        TotalCorrectRateView() // TODO: 실제 정답률 데이터 전달
                        RecommendedQuizView()  // TODO: 실제 추천 퀴즈 데이터 전달
                    }
                }
                
                sectionBackground {
                    CategorySectionView(
                        showingAllCategories: $showingAllCategories,
                        categories: categoryViewModel.categories
                    )
                }
                
                if let attempts = profile.attempts, !attempts.isEmpty {
                    sectionBackground {
                        RecentQuizSectionView(quizAttempts: attempts.sorted(by: { $0.attemptDate > $1.attemptDate }))
                    }
                } else {
                    sectionBackground {
                        VStack(alignment: .leading) {
                            Text("최근 학습")
                                .font(.headline)
                                .padding(.bottom, 10)
                            Text("최근 학습 기록이 없습니다.")
                                .font(.footnote)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            categoryViewModel.fetchCategory()
            id = userID
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: Profile.self, QuizCategory.self, Quiz.self, QuizAttempt.self, configurations: config)
        
        let sampleProfile = Profile(name: "민지", createdAt: Date.now, themeColorHex: "#34C759")
        container.mainContext.insert(sampleProfile)
        
        let sampleCategory1 = QuizCategory(name: "Swift", iconName: "swift", themeColorHex: "#FF9500")
        let sampleCategory2 = QuizCategory(name: "알고리즘", iconName: "slider.horizontal.3", themeColorHex: "#007AFF")
        container.mainContext.insert(sampleCategory1)
        container.mainContext.insert(sampleCategory2)
        
        let sampleQuiz1 = Quiz(questionDescription: "Swift에서 상수를 선언하는 키워드는?", options: ["var", "let", "const"], correctAnswerIndex: 1, difficultyLevel: .level1, quizCategory: sampleCategory1)
        container.mainContext.insert(sampleQuiz1)
        
        let sampleAttempt1 = QuizAttempt(attemptDate: Date().addingTimeInterval(-3600), selectedAnswerIndex: 1, wasCorrect: true, profile: sampleProfile, quiz: sampleQuiz1)
        let sampleAttempt2 = QuizAttempt(attemptDate: Date(), selectedAnswerIndex: 0, wasCorrect: false, profile: sampleProfile, quiz: sampleQuiz1)
        sampleProfile.attempts?.append(sampleAttempt1)
        sampleProfile.attempts?.append(sampleAttempt2)
        
        let categoryVM = CategoryViewModel(modelContext: container.mainContext)
        categoryVM.fetchCategory()
        
        return NavigationStack {
            HomeView(
                profile: sampleProfile,
                navigationPath: .constant(NavigationPath())
            )
            .environmentObject(categoryVM)
            .modelContainer(container)
        }
    }
}
