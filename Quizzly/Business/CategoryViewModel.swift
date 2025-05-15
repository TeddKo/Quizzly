//
//  CategoryViewModel.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/15/25.
//

import Foundation
import SwiftData

class CategoryViewModel: ObservableObject {

    @Published var quizCategories: [QuizCategory] = []
    @Published var quizList: [Quiz] = []
    @Published var categories: [QuizCategory] = []
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCategory()
    }

    func addCategory(_ category: QuizCategory) {
        do {
            modelContext.insert(category)
            try saveContext()
        } catch {
            print(error)
        }
        fetchCategory()
    }

    func fetchCategory() {
        let categoryDescriptor = FetchDescriptor<QuizCategory>()
        do {
            categories = try modelContext.fetch(categoryDescriptor)
        } catch {
            print("Fetch failed: \(error)")
            categories = []
        }
    }

    func deleteCategory(_ category: QuizCategory) {
        modelContext.delete(category)
        do {
            try saveContext()
            fetchCategory()
        } catch {
            print("Error deleting category: \(error)")
        }
    }

    func deleteCategoryAll(_ category: QuizCategory) {
        for model in categories.enumerated() {
            modelContext.delete(model.element)
        }
        do {
            try modelContext.save()
        } catch {
            print(error)
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
        try? saveContext()
        fetchCategory()
    }

    func deleteCategory(item: QuizCategory) {
        modelContext.delete(item)
        try? saveContext()
        fetchCategory()
    }
    
    //    func calculateTotalQuizAttempt() {
    //        let currentUserID = UserDefaults.standard.string(forKey: "currentUserUUID") ?? ""
    //        guard let userUUID = UUID(uuidString: currentUserID) else { return }
    //        let predicate = #Predicate<CategoryProgress> { category in
    //            return category.profile?.id == userUUID
    //        }
    //        let descriptor = FetchDescriptor<CategoryProgress>(predicate: predicate)
    //        var categoryProgress: [CategoryProgress]
    //        do {
    //            categoryProgress = try modelContext.fetch(descriptor)
    //        } catch let e {
    //            print(e)
    //        }
    //    }

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
}
