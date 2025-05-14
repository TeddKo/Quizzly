//
//  EditQuizView.swift
//  Quizzly
//
//  Created by DEV on 5/13/25.
//


//
//  EditQuizView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI

struct EditQuizView: View {
    @Bindable var quiz: Quiz
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel:QuizViewModel

    var body: some View {
        Form {
            Section(header: Text("문제 내용")) {
                TextField("문제를 입력하세요", text: $quiz.questionDescription)
            }

            Section(header: Text("보기 (4개 입력)")) {
                ForEach(0..<4, id: \.self) { index in
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
            
            Section(header: Text("문제 해설 (선택)")) {
                TextEditor(
                    text: Binding(
                        get: { quiz.explanation ?? "" },
                        set: { quiz.explanation = $0 }
                    )
                )
                .frame(height: 100)
            }
            
            Section(header: Text("난이도 선택")) {
                Picker("난이도", selection: $quiz.difficultyLevel) {
                    ForEach(DifficultyLevel.allCases, id: \.self) { level in
                        Text(level.displayName).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
        .onChange(of: quiz){
            try? viewModel.saveContext()
        }
        .navigationTitle("문제 편집")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("완료") {
                    dismiss()
                }
            }
        }
    }
}

#Preview {
//    let sampleCategory = QuizCategory(
//        name: "Swift",
//        iconName: "swift",
//        themeColorHex: "#FF5733"
//    )
//
//    let sampleQuiz = Quiz(
//        questionDescription: "What keyword declares a constant in Swift?",
//        options: ["var", "let", "const", "define"],
//        correctAnswerIndex: 1,
//        explanation: "In Swift, 'let' is used to declare a constant.",
//        difficultyLevel: .level1,
//        quizCategory: sampleCategory, imgPath: ""
//    )
//    
//    EditQuizView(quiz: sampleQuiz)
}
