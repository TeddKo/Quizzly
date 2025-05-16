//
//  QuizListView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI
import SwiftData

struct QuizListView: View {
    let category: QuizCategory
    
    @EnvironmentObject var quizViewModel: QuizViewModel
    
    @State private var showingAddQuizSheet = false
    
    var body: some View {
        NavigationStack {
            
            List {
                ForEach(quizViewModel.filteredQuizzes) { quiz in
                    NavigationLink(value: quiz) {
                        Text(quiz.questionDescription)
                            .lineLimit(2)
                    }
                }
                .onDelete(perform: deleteQuizItemsFromViewModel)
            }
            .navigationTitle("‘\(category.name)’ 퀴즈")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddQuizSheet = true
                    } label: {
                        Label("퀴즈 추가", systemImage: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    if !quizViewModel.filteredQuizzes.isEmpty {
                        EditButton()
                    }
                }
            }
            .sheet(isPresented: $showingAddQuizSheet) {
                AddQuizView()
                    .environmentObject(quizViewModel)
            }
            .navigationDestination(for: Quiz.self) { quiz in
                // EditQuizView에 QuizViewModel 주입
                EditQuizView(quiz: quiz)
                    .environmentObject(quizViewModel)
            }
            
            .overlay {
                if quizViewModel.filteredQuizzes.isEmpty &&
                    !quizViewModel.quizzes.contains(where: { $0.quizCategory?.id == category.id && $0.quizCategory != nil }) {
                    VStack { // ContentUnavailableView 대체
                        Image(systemName: "list.bullet.indent")
                            .font(.largeTitle)
                            .padding(.bottom)
                        Text("'\(category.name)' 카테고리에 아직 퀴즈가 없습니다.")
                            .font(.headline)
                        Button("퀴즈 추가하기") {
                            showingAddQuizSheet = true
                        }
                        .padding(.top)
                        .buttonStyle(.borderedProminent)
                    }
                    .foregroundColor(.gray)
                }
            }
            .onAppear {
                quizViewModel.fetchQuizzes(for: category)
            }
        }
    }
    
    private func deleteQuizItemsFromViewModel(offsets: IndexSet) {
        withAnimation {
            let quizzesToDelete = offsets.map { quizViewModel.filteredQuizzes[$0] }
            for quiz in quizzesToDelete {
                quizViewModel.deleteQuiz(quiz)
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Quiz.self, QuizCategory.self, configurations: config)
    let modelContext = container.mainContext
    
    let sampleCategory = QuizCategory(
        name: "iOS",
        iconName: "iphone",
        themeColorHex: "#34C759"
    )
    modelContext.insert(sampleCategory)
    
    let sampleQuiz1 = Quiz(
        questionDescription: "What is SwiftUI used for?",
        options: ["Networking", "UI Development", "Database", "Audio"],
        correctAnswerIndex: 1,
        explanation: "SwiftUI is Apple's declarative UI framework.",
        difficultyLevel: .level2,
        quizCategory: sampleCategory
    )
    modelContext.insert(sampleQuiz1)
    
    let otherCategory = QuizCategory(name: "Android", iconName: "ladybug")
    modelContext.insert(otherCategory)
    let sampleQuiz2 = Quiz(
        questionDescription: "What is Kotlin?",
        options: ["A UI Framework", "An IDE", "A Programming Language", "A Database"],
        correctAnswerIndex: 2,
        difficultyLevel: .level1,
        quizCategory: otherCategory
    )
    modelContext.insert(sampleQuiz2)
    
    
    let quizVM = QuizViewModel(modelContext: modelContext)
    
    return QuizListView(category: sampleCategory)
        .modelContainer(container)
        .environmentObject(quizVM)
}
