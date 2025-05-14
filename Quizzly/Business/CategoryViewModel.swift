//
//  CategoryViewModel.swift
//  Quizzly
//
//  Created by 김현식 on 5/14/25.
//

import Foundation
import SwiftData
import SwiftUI

class CategoryViewModel: ObservableObject {

    @Published var quizCategories: [QuizCategory] = []
    private var modelContext: ModelContext
    var currentUserID:String = ""
    var tempArray:[CategoryProgress] = []
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchCategory()
    }
    
    func calculateTotalQuizAttempt(){
        currentUserID = UserDefaults.standard.string(forKey: "currentUserUUID") ?? ""
        guard let userUUID = UUID(uuidString: currentUserID) else { return }
        let predicate = #Predicate<CategoryProgress>{ category in
            return category.profile?.id == userUUID
        }
        let descriptor = FetchDescriptor<CategoryProgress>(predicate: predicate)
        do {
            tempArray = try modelContext.fetch(descriptor)
        } catch let e {
            print(e)
        }
    }
    
    func deleteAllCategory(){
        do {
            for item in quizCategories.enumerated() {
                modelContext.delete(item.element)
            }
            try saveContext()
        } catch {
            print("failed")
        }
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
    
    func getCategories()->[QuizCategory]{
        if !quizCategories.isEmpty{
            return quizCategories
        }
        return []
    }

    func updateCategory(name: String, category: QuizCategory) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        fetchCategory()
    }

    func deleteCategory(category: QuizCategory) {
        do {
            modelContext.delete(category)
            try saveContext()
        } catch {
            print(error)
        }
        fetchCategory()
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
