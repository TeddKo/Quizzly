//
//  EditQuizView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI
import SwiftData

fileprivate struct EditQuizView_QuestionSection: View {
    @Bindable var quiz: Quiz

    var body: some View {
        Section(header: Text("문제 내용")) {
            TextField("문제를 입력하세요", text: $quiz.questionDescription)
        }
    }
}

fileprivate struct EditQuizView_OptionsSection: View {
    @Bindable var quiz: Quiz
    
    private var optionIndices: Range<Int> {
        return 0..<4
    }

    var body: some View {
        Section(header: Text("보기 (4개 입력)")) {
            ForEach(optionIndices, id: \.self) { index in
                TextField("보기 \(index + 1)", text: $quiz.options[index])
            }
        }
        
        Section(header: Text("정답 선택")) {
            Picker("정답 보기", selection: $quiz.correctAnswerIndex) {
                ForEach(0..<4, id: \.self) { index in
                    Text("보기 \(index + 1)").tag(index)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

fileprivate struct EditQuizView_ExplanationSection: View {
    @Bindable var quiz: Quiz

    var body: some View {
        Section(header: Text("문제 해설 (선택)")) {
            TextEditor(
                text: Binding(
                    get: { quiz.explanation ?? "" },
                    set: { quiz.explanation = $0.isEmpty ? nil : $0 }
                )
            )
            .frame(height: 100)
        }
    }
}

fileprivate struct EditQuizView_DifficultySection: View {
    @Bindable var quiz: Quiz

    var body: some View {
        Section(header: Text("난이도 선택")) {
            Picker("난이도", selection: $quiz.difficultyLevel) {
                ForEach(DifficultyLevel.allCases, id: \.self) { level in
                    Text(level.displayName).tag(level)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}


struct EditQuizView: View {
    @Bindable var quiz: Quiz
    @EnvironmentObject var quizViewModel: QuizViewModel
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            EditQuizView_QuestionSection(quiz: quiz)
            EditQuizView_OptionsSection(quiz: quiz)
            EditQuizView_ExplanationSection(quiz: quiz)
            EditQuizView_DifficultySection(quiz: quiz)
        }
        .navigationTitle("문제 편집")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("취소") {
                    quizViewModel.rollbackIfNeeded()
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    quizViewModel.saveUpdatedQuiz(quiz)
                    dismiss()
                }
            }
        }
        .onAppear { ensureFourOptions() }
    }

    private func ensureFourOptions() {
        
        if quiz.options.count < 4 {
            let needed = 4 - quiz.options.count
            for _ in 0..<needed {
                quiz.options.append("")
            }
        } else if quiz.options.count > 4 {
            quiz.options = Array(quiz.options.prefix(4))
        }
        if !quiz.options.indices.contains(quiz.correctAnswerIndex) && !quiz.options.isEmpty {
            quiz.correctAnswerIndex = 0
        } else if quiz.options.isEmpty {
            quiz.correctAnswerIndex = 0
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Quiz.self, QuizCategory.self, configurations: config)
    let modelContext = container.mainContext
    
    let sampleCategory = QuizCategory(
        name: "Swift",
        iconName: "swift",
        themeColorHex: "#FF5733"
    )
    modelContext.insert(sampleCategory)

    let sampleQuiz = Quiz(
        questionDescription: "What keyword declares a constant in Swift?",
        options: ["var", "let", "const", "define"],
        correctAnswerIndex: 1,
        explanation: "In Swift, 'let' is used to declare a constant.",
        difficultyLevel: .level1,
        quizCategory: sampleCategory
    )
    modelContext.insert(sampleQuiz)

    let quizVM = QuizViewModel(modelContext: modelContext)
    
    return NavigationView {
        EditQuizView(quiz: sampleQuiz)
    }
    .modelContainer(container)
    .environmentObject(quizVM)
}
