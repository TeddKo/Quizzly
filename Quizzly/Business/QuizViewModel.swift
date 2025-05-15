//
//  ViewModel.swift
//  Quizzly
//
//  Created by DEV on 5/12/25.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

class QuizViewModel: ObservableObject {

    @Published var quizzes: [Quiz] = []
    @Published var category: QuizCategory = QuizCategory(name: "")
    @Published var filterQuizzes: [Quiz] = []
    @Published var attempts: [QuizAttempt] = []
    @Published var startTime: Date = Date.now
    @Published var endTime: Date = Date.now
    @Published var takenTime: Double = 0.0
    @Published var formattedDuration: String = ""
    @Published var oneProblemStartTime: Date = Date.now
    @Published var correctCount: Int = 0
    @Published var totalProblemCount: Int = 0
    @Published var overallScoreRate: Int = 0

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchQuiz()
    }

    func addQuiz(item: Quiz) {
        do {
            modelContext.insert(item)
            try saveContext()
        } catch {
            print(error)
        }
        fetchQuiz()
    }

    func fetchQuiz() {
        let quizDescriptor = FetchDescriptor<Quiz>()
        do {
            quizzes = try modelContext.fetch(quizDescriptor)
        } catch {
            print("Fetch failed: \(error)")
            quizzes = []
        }
    }

    func fetchQuiz(category: QuizCategory) {
        let categorID = category.id
        let predicate = #Predicate<Quiz> { $0.quizCategory?.id == categorID }
        let descriptor = FetchDescriptor<Quiz>(predicate: predicate)
        do {
            filterQuizzes = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            quizzes = []
        }
    }
    

    func answerQuiz(selectedIndex: String, quiz: Quiz) {
        totalProblemCount = totalProblemCount + 1
        let currentUserID = UserDefaults.standard.string(forKey: "currentUserUUID") ?? ""
        guard let uUID = UUID(uuidString: currentUserID) else { return }
        let predicate = #Predicate<Profile> { $0.id == uUID }
        let descriptor = FetchDescriptor<Profile>(predicate: predicate)
        let chosenAnswer = quiz.options.firstIndex(of: selectedIndex) ?? 0
        var isCorrect: Bool = false
        let solvedTime = Date.now
        let duration = solvedTime.timeIntervalSince(oneProblemStartTime)
        if selectedIndex == quiz.correctAnswer {
            isCorrect = true
            correctCount = correctCount + 1
        } else {
            isCorrect = false
            print(isCorrect)
        }
        do {
            try modelContext.transaction {
                let profiles = try modelContext.fetch(descriptor)
                if let profile = profiles.first {
                    modelContext.insert(
                        QuizAttempt(
                            attemptDate: Date.now,
                            selectedAnswerIndex: chosenAnswer,
                            wasCorrect: isCorrect,
                            timeTaken: duration,
                            profile: profile,
                            quiz: quiz
                        )
                    )
                }
                try saveContext()
            }
        } catch {
            print(error)
        }
    }

    func calculateTotalDuration() {
        let duration = endTime.timeIntervalSince(startTime)
        takenTime = duration
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = [.pad]
        formattedDuration = formatter.string(from: duration) ?? "0:00"
    }

    func filteredQuizByLevel(level: Int) {
        let predicate = #Predicate<Quiz> { quiz in
            quiz.difficultyLevel.rawValue > level
        }
        let discriptor = FetchDescriptor<Quiz>(predicate: predicate)
        do {
            quizzes = try modelContext.fetch(discriptor)
        } catch {
            print("Filtering Error")
        }
    }

    func filteredQuizByCategory(category: String) {
        let predicate = #Predicate<Quiz> { quiz in
            quiz.quizCategory?.name.contains(category) ?? false
        }
        let discriptor = FetchDescriptor<Quiz>(predicate: predicate)
        do {
            quizzes = try modelContext.fetch(discriptor)
        } catch {
            print("Filtering Error")
        }
    }

    func saveContext() throws {
        if modelContext.hasChanges {
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                print(error)
            }
        }
    }

    func deleteQuiz(quiz: Quiz) {
        do {
            modelContext.delete(quiz)
            try saveContext()
        } catch {
            print(error)
        }
        fetchQuiz()
    }
}
