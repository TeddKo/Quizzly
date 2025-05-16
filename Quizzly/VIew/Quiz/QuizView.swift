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

fileprivate struct TimeProgressView: View {
    let elapsedTime: TimeInterval
    let timeLimit: TimeInterval
    let formattedTime: String
    
    private var progress: Double {
        guard timeLimit > 0 else { return 0 }
        return min(elapsedTime / timeLimit, 1.0) // 0.0 ~ 1.0 사이 값
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("남은 시간")
                    .font(.caption2)
                    .foregroundColor(.gray)
                Spacer()
                Text(formattedTime)
                    .font(.caption.bold())
                    .foregroundColor(.blue)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 10)
                    
                    Capsule()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [.blue.opacity(0.7), .blue]),
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: geometry.size.width * CGFloat(progress), height: 10)
                        .animation(.linear(duration: 0.1), value: progress) // 부드러운 애니메이션
                }
                .clipShape(Capsule())
            }
            .frame(height: 10)
        }
    }
}

// MARK: QuizView
struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Binding var navigationPath: NavigationPath
    
    // 기존 상태 변수들
    @State private var selectedOption: String? = nil
    @State private var currentIndex: Int = 0
    @State private var showResult: Bool = false
    @State private var correctCount: Int = 0
    @State private var wrongNotes: [QuizNote] = []
    @State private var userAnswers: [Int] = []
    @State private var fetchedQuizzesForCategory: [Quiz] = []
    @State private var quizStartTime: Date? = nil
    @State private var elapsedTime: TimeInterval = 0
    @State private var timerSubscription: Timer.TimerPublisher.Output? = nil
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var totalQuizTimeTaken: String = "00:00"
    let quizTimeLimit: TimeInterval = 600
    
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
            TimeProgressView(
                elapsedTime: elapsedTime,
                timeLimit: quizTimeLimit,
                formattedTime: formatTime(quizTimeLimit - elapsedTime)
            )
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
                    stopTimer()
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
                totalTime: totalQuizTimeTaken,
                scorePercentage: fetchedQuizzesForCategory.isEmpty ? 0 : Int((Double(correctCount) / Double(fetchedQuizzesForCategory.count)) * 100),
                quizTitle: "\(category.name) 퀴즈 결과",
                notes: wrongNotes,
                recommendations: [],
                currentCategory: category
            )
        }
        .onAppear {
            fetchQuizzesForCurrentCategory()
            resetQuizStateAndTimer()
            print("--- QuizView onAppear ---")
            print("Category: \(category.name)")
            print("Fetched quizzes count for category: \(fetchedQuizzesForCategory.count)")
        }
        .onDisappear {
            stopTimer()
        }
        .onReceive(timer) { firedDate in
            guard quizStartTime != nil, !showResult else {
                return
            }
            let currentElapsedTime = Date().timeIntervalSince(quizStartTime ?? .now)
            // 시간이 다 되면 자동으로 퀴즈 종료 (선택 사항)
            if currentElapsedTime >= quizTimeLimit {
                self.elapsedTime = quizTimeLimit // 정확히 제한 시간으로 설정
                handleQuizTimeout()
            } else {
                self.elapsedTime = currentElapsedTime
            }
        }
        .onChange(of: category) { _, newCategory in
            print("Category changed to: \(newCategory.name). Fetching quizzes.")
            stopTimer()
            fetchQuizzesForCurrentCategory()
            resetQuizStateAndTimer()
        }
    }
    
    private func handleQuizTimeout() {
        print("Quiz time is up!")
        stopTimer()
        totalQuizTimeTaken = formatTime(quizTimeLimit)
        _ = Array(fetchedQuizzesForCategory.prefix(currentIndex + 1))
        
        evaluateQuizResults(from: fetchedQuizzesForCategory)
        showResult = true
    }
    
    private func startTimer() {
        quizStartTime = Date()
        elapsedTime = 0
        print("Timer started at \(String(describing: quizStartTime))")
    }
    
    private func stopTimer() {
        quizStartTime = nil
        // self.timerSubscription?.cancel()
        print("Timer stopped. Final elapsed time: \(elapsedTime)")
    }
    
    private func formatTime(_ interval: TimeInterval) -> String {
        let totalSeconds = Int(interval)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func fetchQuizzesForCurrentCategory() {
        let categoryID = category.id
        let predicate = #Predicate<Quiz> { quiz in
            quiz.quizCategory?.id == categoryID
        }
        let descriptor = FetchDescriptor<Quiz>(predicate: predicate, sortBy: [SortDescriptor(\Quiz.questionDescription)])
        
        do {
            fetchedQuizzesForCategory = try modelContext.fetch(descriptor)
            print("Successfully fetched \(fetchedQuizzesForCategory.count) quizzes for category \(category.name).")
        } catch {
            print("Failed to fetch quizzes for category '\(category.name)': \(error.localizedDescription)")
            fetchedQuizzesForCategory = []
        }
    }
    
    private func resetQuizStateAndTimer() {
        selectedOption = nil
        currentIndex = 0
        correctCount = 0
        wrongNotes = []
        userAnswers = []
        showResult = false
        startTimer()
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
            stopTimer()
            totalQuizTimeTaken = formatTime(elapsedTime)
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
                originalQuizID: quiz.id,
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
