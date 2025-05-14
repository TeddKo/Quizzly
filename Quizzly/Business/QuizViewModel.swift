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

    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchQuiz()
    }

    //    TODO: - CRUD (quizs)
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

    func answerQuiz(startDate: Date, chsoenAnswer: Int, quiz: Quiz, attempt: QuizAttempt) {
        do {
            if quiz.correctAnswerIndex == chsoenAnswer {
                attempt.selectedAnswerIndex = chsoenAnswer
                attempt.wasCorrect = true
                attempt.attemptDate = Date.now
                attempt.timeTaken = startDate.timeIntervalSince(Date.now)
            }
            try saveContext()
        } catch {
            print(error)
        }
    }

    func deleteQuiz(at offsets: IndexSet) {
        do {
            let quizzesToDelete = offsets.map { quizzes[$0] }
            quizzesToDelete.forEach { quiz in
                modelContext.delete(quiz)
            }
            try saveContext()
        } catch {
            print(error)
        }
        fetchQuiz()
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
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            modelContext.rollback()
            print(error)
        }
    }
}
