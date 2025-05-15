//
//  QuizView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

fileprivate struct QuizOptionRowView: View {
    let optionText: String
    @Binding var selectedOption: String?
    var isSelected: Bool { selectedOption == optionText }
    var body: some View {
        Button { selectedOption = optionText } label: {
            Text(optionText).bold().foregroundStyle(isSelected ? .cyan : .black)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 24)
        .background(RoundedRectangle(cornerRadius: 12).stroke(isSelected ? Color.cyan : Color.gray.opacity(0.5), lineWidth: 2))
    }
}

fileprivate struct QuizOptionsListView: View {
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

fileprivate struct QuizQuestionView: View {
    let questionDescription: String
    var body: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20).fill(.gray.opacity(0.5)).frame(maxWidth: .infinity, maxHeight: 200)
                .overlay { Text(questionDescription).bold().foregroundStyle(.black).multilineTextAlignment(.center).padding() }
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
    @State private var wrongNotes: [QuizNote] = []
    @State private var userAnswers: [Int] = []
    
    @State private var fetchedQuizzesForCategory: [Quiz] = []

    let category: QuizCategory
    let difficulty: DifficultyLevel
    
    private var currentQuiz: Quiz? {
        guard !fetchedQuizzesForCategory.isEmpty, fetchedQuizzesForCategory.indices.contains(currentIndex) else {
            return nil
        }
        return fetchedQuizzesForCategory[currentIndex]
    }

    var body: some View {
        VStack(spacing: 30) {
            if let quiz = currentQuiz {
                QuizQuestionView(questionDescription: quiz.questionDescription)
                QuizOptionsListView(options: quiz.options, selectedOption: $selectedOption)
                Button {
                    handleNextButtonTap(for: quiz)
                } label: {
                    Text(currentIndex == fetchedQuizzesForCategory.count - 1 ? "Finish" : "Next")
                        .tint(.white).bold().padding().frame(maxWidth: .infinity).background(.cyan).clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .background { RoundedRectangle(cornerRadius: 12).foregroundStyle(.cyan).offset(y: 10).opacity(0.4).blur(radius: 12) }
                .disabled(selectedOption == nil && currentIndex < fetchedQuizzesForCategory.count)
            } else {
                ContentUnavailableView(
                    "퀴즈 없음",
                    systemImage: "questionmark.diamond",
                    description: Text("'\(category.name)' 카테고리에 해당하는 퀴즈가 아직 없습니다.")
                )
            }
        }
        .padding(.horizontal)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if navigationPath.count > 0 { navigationPath.removeLast() } else { dismiss() }
                }) {
                    Image(systemName: "xmark")
                        .resizable().scaledToFit().frame(width: 14, height: 14).bold().foregroundColor(.black)
                        .frame(width: 36, height: 36).overlay(Circle().stroke(.black.opacity(0.5), lineWidth: 1.3))
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $showResult) {
            QuizResultView(
                navigationPath: $navigationPath,
                correctCount: correctCount,
                incorrectCount: fetchedQuizzesForCategory.count - correctCount,
                totalTime: "03:24", // TODO: 실제 시간 측정
                scorePercentage: fetchedQuizzesForCategory.isEmpty ? 0 : Int((Double(correctCount) / Double(fetchedQuizzesForCategory.count)) * 100),
                quizTitle: "\(category.name) 퀴즈 결과",
                notes: wrongNotes,
                recommendations: [],
                currentCategory: category
            )
        }
        .onAppear {
            fetchQuizzesForCurrentCategory()
            resetQuizState()
            print("--- QuizView onAppear ---")
            print("Category: \(category.name)")
            print("Fetched quizzes count for category: \(fetchedQuizzesForCategory.count)")
        }
        .onChange(of: category) { _, newCategory in // category가 바뀔 때만 퀴즈 다시 로드
            print("Category changed to: \(newCategory.name). Fetching quizzes.")
            fetchQuizzesForCurrentCategory()
            resetQuizState()
        }
    }
    
    private func fetchQuizzesForCurrentCategory() {
        let categoryID = category.id
        
        let predicate = #Predicate<Quiz> { quiz in
            quiz.quizCategory?.id == categoryID
        }
        let descriptor = FetchDescriptor<Quiz>(
            predicate: predicate,
            sortBy: [SortDescriptor(\Quiz.questionDescription)]
        )
        
        do {
            fetchedQuizzesForCategory = try modelContext.fetch(descriptor)
            print("Successfully fetched \(fetchedQuizzesForCategory.count) quizzes for category \(category.name).")
        } catch {
            print("Failed to fetch quizzes for category '\(category.name)': \(error.localizedDescription)")
            fetchedQuizzesForCategory = []
        }
    }

    private func resetQuizState() {
        selectedOption = nil
        currentIndex = 0
        correctCount = 0
        wrongNotes = []
        userAnswers = []
        showResult = false
    }
    
    private func handleNextButtonTap(for quiz: Quiz) {
        if let selected = selectedOption,
           let selectedIndexInOptions = quiz.options.firstIndex(of: selected) {
             userAnswers.append(selectedIndexInOptions)
             if selectedIndexInOptions == quiz.correctAnswerIndex {
                 correctCount += 1
             }
         } else {
             userAnswers.append(-1)
         }

        if currentIndex < fetchedQuizzesForCategory.count - 1 {
            currentIndex += 1
            selectedOption = nil
        } else {
            evaluateQuizResults(from: fetchedQuizzesForCategory)
            showResult = true
        }
    }
    
    func evaluateQuizResults(from quizzes: [Quiz]) {
        wrongNotes = quizzes.enumerated().compactMap { index, quiz in
            guard userAnswers.indices.contains(index) else { return nil }
            let userAnswerIndex = userAnswers[index]
            
            guard let correctAnswerText = quiz.options[safe: quiz.correctAnswerIndex],
                  let selectedAnswerText = quiz.options[safe: userAnswerIndex],
                  userAnswerIndex != quiz.correctAnswerIndex else {
                return nil
            }
            
            let noteChoices = quiz.options.enumerated().map { idx, optionText in
                Choice(label: String(UnicodeScalar(65 + idx)!), text: optionText)
            }

            return QuizNote(
                originalQuizID: quiz.id, // 원본 Quiz의 ID
                question: quiz.questionDescription,
                userAnswer: selectedAnswerText,
                correctAnswer: correctAnswerText,
                explanation: quiz.explanation ?? "해설이 제공되지 않았습니다.",
                level: quiz.difficultyLevel.displayName,
                category: quiz.quizCategory?.name ?? "미지정",
                dateAdded: formattedDate(),
                choices: noteChoices,
                recommendations: [],
                memo: ""
            )
        }
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter(); formatter.dateFormat = "yyyy년 M월 d일"; return formatter.string(from: Date())
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    let sampleCategory = QuizCategory(name: "Sample Category", iconName: "swift", themeColorHex: "#3498db")
    
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Quiz.self, Quiz
        .self, configurations: config)
    
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
