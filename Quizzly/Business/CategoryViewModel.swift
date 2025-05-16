//
//  CategoryViewModel.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/15/25.
//

import Foundation
import SwiftData

class CategoryViewModel: ObservableObject {
    
    @Published var categories: [QuizCategory] = []
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
