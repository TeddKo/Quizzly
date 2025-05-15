//
//  QuizViewModel.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/16/25.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class QuizViewModel: ObservableObject {
    
    @Published var quizzes: [Quiz] = []
    @Published var selectedQuiz: Quiz?
    @Published var filteredQuizzes: [Quiz] = []
    
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchQuizzes()
    }
    
    func addQuiz(questionDescription: String, options: [String], correctAnswerIndex: Int, explanation: String?, difficultyLevel: DifficultyLevel, category: QuizCategory, imagePath: String? = nil) {
        guard !options.isEmpty, options.indices.contains(correctAnswerIndex) else {
            print("Error: Invalid options or correctAnswerIndex for new quiz.")
            return
        }
        let newQuiz = Quiz(
            questionDescription: questionDescription,
            options: options,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation,
            difficultyLevel: difficultyLevel,
            quizCategory: category,
            imagePath: imagePath
        )
        modelContext.insert(newQuiz)
        saveContextAndRefreshQuizzes(operationDescription: "add quiz")
    }
    

    func fetchQuizzes() {
        let descriptor = FetchDescriptor<Quiz>(sortBy: [SortDescriptor(\Quiz.questionDescription)])
        do {
            quizzes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch quizzes: \(error.localizedDescription)")
            quizzes = []
        }
    }
    
    func fetchQuizzes(for category: QuizCategory) {
        let categoryID = category.id
        let predicate = #Predicate<Quiz> { quiz in
            quiz.quizCategory?.id == categoryID
        }
        let descriptor = FetchDescriptor<Quiz>(predicate: predicate, sortBy: [SortDescriptor(\Quiz.questionDescription)])
        do {
            filteredQuizzes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch quizzes for category \(category.name): \(error.localizedDescription)")
            filteredQuizzes = []
        }
    }
    
    func fetchQuizzes(for category: QuizCategory, difficulty: DifficultyLevel) {
        let categoryID = category.id
        let predicate = #Predicate<Quiz> { quiz in
            quiz.quizCategory?.id == categoryID && quiz.difficultyLevel == difficulty
        }
        let descriptor = FetchDescriptor<Quiz>(predicate: predicate, sortBy: [SortDescriptor(\Quiz.questionDescription)])
        do {
            filteredQuizzes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch quizzes for category \(category.name) and difficulty \(difficulty.displayName): \(error.localizedDescription)")
            filteredQuizzes = []
        }
    }
    
    func fetchQuiz(by id: UUID) -> Quiz? {
        let predicate = #Predicate<Quiz> { $0.id == id }
        var descriptor = FetchDescriptor<Quiz>(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to fetch quiz with id \(id): \(error.localizedDescription)")
            return nil
        }
    }
    
    func saveUpdatedQuiz(_ quiz: Quiz) {
        print("QuizViewModel: Attempting to save updated quiz '\(quiz.questionDescription)'")
        saveContextAndRefreshQuizzes(operationDescription: "update quiz")
    }
    
    func deleteQuiz(_ quizToDelete: Quiz) {
        modelContext.delete(quizToDelete)
        saveContextAndRefreshQuizzes(operationDescription: "delete quiz")
    }
    
    func deleteQuizzes(at offsets: IndexSet, from quizArray: [Quiz]) {
        offsets.map { quizArray[$0] }.forEach(modelContext.delete)
        saveContextAndRefreshQuizzes(operationDescription: "delete multiple quizzes")
    }
    
    private func saveContextAndRefreshQuizzes(operationDescription: String) {
        do {
            try modelContext.save()
            print("QuizViewModel: Context saved successfully after \(operationDescription).")
            fetchQuizzes()
        } catch {
            print("QuizViewModel: Failed to save context after \(operationDescription): \(error.localizedDescription)")
            modelContext.rollback()
            print("QuizViewModel: Context rolled back due to save failure.")
        }
    }
    
    func rollbackIfNeeded() {
        if modelContext.hasChanges {
            modelContext.rollback()
            print("QuizViewModel: Changes rolled back via rollbackIfNeeded.")
        } else {
            print("QuizViewModel: No changes to roll back.")
        }
    }
}
