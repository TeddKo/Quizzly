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
        modelContext.insert(item)
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
        if quiz.correctAnswerIndex == chsoenAnswer {
            attempt.selectedAnswerIndex = chsoenAnswer
            attempt.wasCorrect = true
            attempt.attemptDate = Date.now
            attempt.timeTaken = startDate.timeIntervalSince(Date.now)
        }
    }
    
    func deleteQuiz(at offsets: IndexSet) {
        print(offsets)
        let quizzesToDelete = offsets.map { quizzes[$0] }
        quizzesToDelete.forEach { quiz in
            modelContext.delete(quiz)
        }
        
        fetchQuiz()
    }

    //추천학습
    //#1.wasCorrect가 false인 것듯을 카운팅
    //#2.가장 많은 것을 추천학습으로 표현
    //
    //오답노트
    //#1.틀린 문제들을 정렬해서 오답노트라고 다시 보여줌
    //

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

    func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch {
            print(error)
        }
    }
}
