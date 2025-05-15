//
//  CategoryViewModel.swift
//  Quizzly
//
//  Created by DEV on 5/13/25.
//

//
//  CategoryViewModel.swift
//  Quizzly
//
//  Created by DEV on 5/13/25.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

class CategoryViewModel: ObservableObject {

    @Published var quizCategories: [QuizCategory] = []
    @Published var quizList:[Quiz] = []
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCategory()
        modelDeleteAll()
        updateDummyQuiz()
    }

    func addCategory(item: QuizCategory) {
        modelContext.insert(item)
        saveContext()
        fetchCategory()
    }

    func fetchCategory() {
        let descriptor = FetchDescriptor<QuizCategory>()
        do {
            quizCategories = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            quizCategories = []
        }
    }

    func updateDummyQuiz() {
        let quizList: [Quiz] = [
            Quiz(
                questionDescription: "What is the most popular sport throughout the world?",
                options: ["Volleyball", "Football", "Basketball", "Badminton"],
                correctAnswerIndex: 1,
                difficultyLevel: .level1,
                quizCategory: QuizCategory(name: "World", iconName: "globe", themeColorHex: "#3498db")
            ),
            Quiz(
                questionDescription: "Which keyword is used to define a constant in Swift?",
                options: ["let", "var", "const", "def"],
                correctAnswerIndex: 0,
                difficultyLevel: .level1,
                quizCategory: QuizCategory(name: "Swift", iconName: "swift", themeColorHex: "#e67e22")
            )
        ]
        let quizCategoryList:[QuizCategory] = [
            QuizCategory(name: "자료구조", iconName: "doc.on.clipboard"),
            QuizCategory(name: "Swift",iconName: "swift")
        ]
        do {
            try modelContext.transaction {
                quizList.map { $0 }.forEach(modelContext.insert)
                quizCategoryList.map{$0}.forEach(modelContext.insert)
            }
        } catch let e {
            print(e)
        }
        do {
            try saveContext()
        } catch let e {
            print(e)
        }
    }

    func modelDeleteAll() {
//        for item in quizCategories.enumerated() {
//            modelContext.delete(item.element)
//            do {
//                try saveContext()
//            } catch let e {
//                print(e)
//            }
//        }
//        for item in quizList.enumerated() {
//            modelContext.delete(item.element)
//            do {
//                try saveContext()
//            } catch let e {
//                print(e)
//            }
//        }
        let predicate = #Predicate<Quiz>{
            $0.questionDescription.isEmpty == false
        }
        try? modelContext.delete(model: Quiz.self, where: predicate)
        do {
            try saveContext()
        } catch let e {
            print(e)
        }
    }

    func getCategories() -> [QuizCategory] {
        var categories: [QuizCategory]
        let descriptor = FetchDescriptor<QuizCategory>()
        do {
            categories = try modelContext.fetch(descriptor)
            return categories
        } catch let e {
            print(e)
            return []
        }
    }

    func updateCategory(name: String, category: QuizCategory) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("name can be empty")
            return
        }
        saveContext()
        fetchCategory()
    }

    func deleteCategory(item: QuizCategory) {
        modelContext.delete(item)
        saveContext()
        fetchCategory()
    }

    func calculateTotalQuizAttempt() {
        let currentUserID = UserDefaults.standard.string(forKey: "currentUserUUID") ?? ""
        guard let userUUID = UUID(uuidString: currentUserID) else { return }
        let predicate = #Predicate<CategoryProgress> { category in
            return category.profile?.id == userUUID
        }
        let descriptor = FetchDescriptor<CategoryProgress>(predicate: predicate)
        var categoryProgress: [CategoryProgress]
        do {
            categoryProgress = try modelContext.fetch(descriptor)
            print(categoryProgress)
        } catch let e {
            print(e)
        }
    }

    func saveContext() {
        do {
            if modelContext.hasChanges {
                try modelContext.save()
            }
        } catch let e {
            print(e)
        }
    }
    
//    취약카테고리
//    wasCorrect가 false인것을 카운팅해서 가장 많은 것
//    func findWeakness(){
//        
//        modelContext.insert(QuizAttempt(attemptDate: Date.now, selectedAnswerIndex: 3, wasCorrect: false, profile: Profile(name: "Jack", createdAt: Date.now), quiz: Quiz(questionDescription: "강사님 성은", options: ["김","이","박","최"], correctAnswerIndex: 4, difficultyLevel: .level1, quizCategory: QuizCategory(name: "상식"))))
//        saveContext()
//    }
}
