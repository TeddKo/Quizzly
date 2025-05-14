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

    @Environment(\.modelContext) private var modelContext

    @Query private var allQuizzes: [Quiz]

    @State private var showingAddQuizSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(allQuizzes) { quiz in
                    NavigationLink(value: quiz) {
                        Text(quiz.questionDescription)
                            .lineLimit(2)
                    }
                }
                .onDelete(perform: deleteQuizzes)
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
                    EditButton()
                }
            }
            
            .sheet(isPresented: $showingAddQuizSheet) {
                AddQuizView(quizCategory: category)
            }
            
            .navigationDestination(for: Quiz.self) { quiz in
                EditQuizView(quiz: quiz)
            }
        }
    }
    
    private func deleteQuizzes(offsets: IndexSet) {
        withAnimation {
            offsets.map { allQuizzes[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    let sampleCategory = QuizCategory(
        name: "iOS",
        iconName: "iphone",
        themeColorHex: "#34C759"
    )

    let sampleQuiz = Quiz(
        questionDescription: "What is SwiftUI used for?",
        options: ["Networking", "UI Development", "Database", "Audio"],
        correctAnswerIndex: 1,
        explanation: "SwiftUI is Apple's declarative UI framework.",
        difficultyLevel: .level2,
        quizCategory: sampleCategory
    )

    let container = try! ModelContainer(for: Quiz.self, QuizCategory.self, configurations: .init(isStoredInMemoryOnly: true))
    container.mainContext.insert(sampleCategory)
    container.mainContext.insert(sampleQuiz)

    return QuizListView(category: sampleCategory)
        .modelContainer(container)
}
