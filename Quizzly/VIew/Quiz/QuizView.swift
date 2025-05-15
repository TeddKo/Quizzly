//
//  QuizView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

// MARK: QuizOptionRowView
struct QuizOptionRowView: View {
    let optionText: String
    @Binding var selectedOption: String?

    var isSelected: Bool {
        selectedOption == optionText
    }

    var body: some View {
        Button {
            selectedOption = optionText
        } label: {
            Text(optionText)
                .bold()
                .foregroundStyle(isSelected ? .cyan : .black)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    isSelected ? Color.cyan : Color.gray.opacity(0.5),
                    lineWidth: 2
                )
        )
    }
}

// MARK: QuizOptionsListView
struct QuizOptionsListView: View {
    let options: [String]
    @Binding var selectedOption: String?

    var body: some View {
        VStack(spacing: 12) {
            ForEach(options, id: \.self) { optionText in
                QuizOptionRowView(optionText: optionText, selectedOption: $selectedOption)
            }
        }
    }
}

// MARK: QuizQuestionView
struct QuizQuestionView: View {
    let questionDescription: String

    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.gray.opacity(0.5))
                .frame(maxWidth: .infinity, maxHeight: 200)
                .overlay {
                    Text(questionDescription)
                        .bold()
                        .foregroundStyle(.black)
                        .multilineTextAlignment(.center)
                        .padding()
                }
        }
    }
}

// MARK: QuizView
struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var navigationPath: NavigationPath

    @State private var selectedOption: String? = nil
    @State private var currentIndex: Int = 0
    @State private var showResult: Bool = false
    @State private var correctCount: Int = 0

    @Query(sort: \Quiz.questionDescription) private var allFetchedQuizzes: [Quiz]
    
    let category: QuizCategory
    let difficulty: DifficultyLevel
    
    private var filteredQuizzes: [Quiz] {
        allFetchedQuizzes.filter { quiz in
            (quiz.quizCategory?.id == category.id) && (quiz.difficultyLevel == difficulty)
        }
    }
    
    private var currentQuiz: Quiz? {
        guard !filteredQuizzes.isEmpty, filteredQuizzes.indices.contains(currentIndex) else {
            return nil
        }
        return filteredQuizzes[currentIndex]
    }

    var body: some View {
        VStack(spacing: 30) {
            if let quiz = currentQuiz {
                QuizQuestionView(questionDescription: quiz.questionDescription)
                
                QuizOptionsListView(options: quiz.options, selectedOption: $selectedOption)
                
                Button {
                    handleNextButtonTap(for: quiz)
                } label: {
                    Text(currentIndex == filteredQuizzes.count - 1 ? "Finish" : "Next")
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
                .disabled(selectedOption == nil && currentIndex < filteredQuizzes.count)
            } else {
                ContentUnavailableView(
                    "퀴즈 없음",
                    systemImage: "questionmark.diamond",
                    description: Text("선택하신 카테고리와 난이도에 해당하는 퀴즈가 아직 없습니다.")
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
        .navigationDestination(isPresented: $showResult) {
            QuizResultView(
                navigationPath: $navigationPath,
                correctCount: correctCount,
                incorrectCount: filteredQuizzes.count - correctCount,
                totalTime: "03:24", // TODO: 실제 시간 측정 로직 추가
                scorePercentage: filteredQuizzes.isEmpty ? 0 : Int((Double(correctCount) / Double(filteredQuizzes.count)) * 100),
                quizTitle: "\(category.name) 퀴즈",
                // TODO: 오답 노트 및 추천 학습 데이터 구성
                notes: [],
                recommendations: [],
                category: category
            )
        }
        .onAppear {
            if filteredQuizzes.isEmpty {
                print("선택된 카테고리/난이도에 해당하는 퀴즈가 없습니다.")
            }
        }
    }
    
    private func handleNextButtonTap(for quiz: Quiz) {
        if let selected = selectedOption,
           selected == quiz.options[quiz.correctAnswerIndex] {
            correctCount += 1
        }

        if currentIndex < filteredQuizzes.count - 1 {
            currentIndex += 1
            selectedOption = nil
        } else {
            showResult = true
        }
    }
}

extension Quiz {
    var correctAnswerString: String {
        guard options.indices.contains(correctAnswerIndex) else {
            return ""
        }
        return options[correctAnswerIndex]
    }
}


#Preview {
    let sampleCategory = QuizCategory(name: "Sample Category", iconName: "swift", themeColorHex: "#3498db")
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Quiz.self, QuizCategory.self, configurations: config)
    
    let quiz1 = Quiz(
        questionDescription: "What is the capital of France?",
        options: ["Berlin", "Madrid", "Paris", "Rome"],
        correctAnswerIndex: 2,
        difficultyLevel: .level1,
        quizCategory: sampleCategory
    )
    let quiz2 = Quiz(
        questionDescription: "Which planet is known as the Red Planet?",
        options: ["Earth", "Mars", "Jupiter", "Saturn"],
        correctAnswerIndex: 1,
        difficultyLevel: .level1,
        quizCategory: sampleCategory
    )
    container.mainContext.insert(sampleCategory)
    container.mainContext.insert(quiz1)
    container.mainContext.insert(quiz2)
    
    return QuizView(
        navigationPath: .constant(NavigationPath()),
        category: sampleCategory,
        difficulty: .level1
    )
    .modelContainer(container)
}
