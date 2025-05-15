//
//  QuizzView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var navigationPath: NavigationPath

    @State private var ratio: CGFloat = 0.5
    @State private var selectedOption: String? = nil
    @State private var currentIndex: Int = 0
    @State private var showResult: Bool = false
    @State private var correctCount: Int = 0
    
    let category: QuizCategory
    let difficulty: DifficultyLevel
    let questions: [Quiz]
    
    var body: some View {
        VStack(spacing: 30) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.opacity(0.5))
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .overlay {
                        Text(questions[currentIndex].questionDescription)
                            .bold()
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                    }
            }
            
            VStack(spacing: 12) {
                ForEach(questions[currentIndex].options, id: \.self) { option in
                    Button {
                        selectedOption = option
                    } label: {
                        Text(option)
                            .bold()
                            .foregroundStyle(selectedOption == option ? .cyan : .black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedOption == option ? Color.cyan : Color.gray.opacity(0.5),
                                lineWidth: 2
                            )
                    )
                }
            }
            
            Button {
                if let selected = selectedOption,
                   selected == questions[currentIndex].correctAnswer {
                    correctCount += 1
                }

                if currentIndex < questions.count - 1 {
                    currentIndex += 1
                    selectedOption = nil
                } else {
                    showResult = true
                }
            } label: {
                Text(currentIndex == questions.count - 1 ? "Finish" : "Next")
                    .tint(.white)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.cyan)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.cyan)
                    .offset(y: 10)
                    .opacity(0.4)
                    .blur(radius: 12)
            }
            
            .navigationDestination(isPresented: $showResult) {
                QuizResultView(
                    navigationPath: $navigationPath,
                    correctCount: correctCount,
                    incorrectCount: questions.count - correctCount,
                    totalTime: "03:24",
                    notes: [],
                    scorePercentage: Int((Double(correctCount) / Double(questions.count)) * 100),
                    quizTitle: "\(category.name) 퀴즈",
                    recommendations: [],
                    category: category,
                    questions: questions
                )
            }

        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 14, height: 14)
                        .bold()
                        .foregroundColor(.black)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Circle()
                                .stroke(.black.opacity(0.5), lineWidth: 1.3)
                        )
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

extension Quiz {
    var correctAnswer: String {
        return options[correctAnswerIndex]
    }
}
