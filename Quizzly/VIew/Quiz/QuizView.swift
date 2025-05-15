//
//  QuizzView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftData
import SwiftUI

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @Binding var navigationPath: NavigationPath

    @State private var ratio: CGFloat = 0.5
    @State private var selectedOption: String? = nil
    @State private var currentIndex: Int = 0
    @State private var showResult: Bool = false
    @State private var correctCount: Int = 0
    @EnvironmentObject var categoryViewModel: CategoryViewModel
    @EnvironmentObject var quizViewModel: QuizViewModel

    @Query(sort: \Quiz.questionDescription) private var quizzes: [Quiz]

    var category: QuizCategory
    var difficulty: DifficultyLevel

    // TODO: mock 데이터 실제 데이터로 바꾸기
    let mockOptions = [
        "Volleyball",
        "Football",
        "Basketball",
        "Badminton",
    ]
    @State var quizList: [Quiz] = []
    @State var isCount: Int = 0

    var body: some View {
        VStack(spacing: 30) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(isCount != 0 ? .gray.opacity(0.5) : .clear)
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .overlay {
                        Text(isCount != 0 ? quizList[currentIndex].questionDescription : "")
                            .bold()
                            .foregroundStyle(.black)
                            .multilineTextAlignment(.center)
                    }
            }

            VStack(spacing: 12) {
                ForEach(isCount != 0 ? quizList[currentIndex].options : [], id: \.self) { option in
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
                    selected == quizList[currentIndex].correctAnswer
                {
                    correctCount += 1
                }

                if currentIndex < quizList.count - 1 {
                    currentIndex += 1
                    selectedOption = nil
                } else {
                    showResult = true
                    quizViewModel.endTime = Date.now
                }
            } label: {
                Text(currentIndex == quizList.count - 1 ? "Finish" : "Next")
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
            .opacity(isCount != 0 ? 100 : 0 )
            .navigationDestination(isPresented: $showResult) {
                //                QuizResultView(
                //                    navigationPath: $navigationPath,
                //                    correctCount: correctCount,
                //                    incorrectCount: quizList.count - correctCount,
                //                    totalTime: "03:24",
                //                    scorePercentage: Int((Double(correctCount) / Double(quizList.count)) * 100),
                //                    quizTitle: "\(category.title) 퀴즈",
                //                    notes: [],
                //                    recommendations: [],
                //                    category: category
                //                )
            }
            .onAppear {
                quizViewModel.fetchQuiz(category: category)
                quizList = quizViewModel.filterQuizzes
                isCount = quizList.count
                quizViewModel.startTime = Date.now
            }
            .onDisappear {
                quizViewModel.calculateDuration()
                print(quizViewModel.formattedDuration)
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
