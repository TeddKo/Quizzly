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
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCategory()
    }
    
    func addCategory(item: QuizCategory) {
        modelContext.insert(item)
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
    
    func updateCategory(name: String, category: QuizCategory) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("name can be empty")
            return
        }
        fetchCategory()
    }
    
    func deleteCategory(item: QuizCategory) {
        modelContext.delete(item)
        fetchCategory()
    }
}


