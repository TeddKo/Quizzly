//
//  HomeViewModel.swift
//  Quizzly
//
//  Created by DEV on 5/14/25.
//

import Foundation
import SwiftData
import SwiftUI

class HomeViewModel: ObservableObject {

    @Published var profiles: [Profile] = []
    @Published var overallScoreRate:Int = 0
    @Published var totalCount: Int = 0
    @Published var answerCount: Int = 0
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        getOverallScoreRate()
    }

    func addProfile(item: Profile) {
        do {
            modelContext.insert(item)
            try saveContext()
        } catch {
            print(error)
        }
        fetchProfile()
    }

    func fetchProfile() {
        let profileDescriptor = FetchDescriptor<Profile>()
        do {
            profiles = try modelContext.fetch(profileDescriptor)
        } catch {
            print("Fetch failed \(error)")
            profiles = []
        }
    }

    func deleteProfile() {
        for model in profiles.enumerated() {
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
    
    func getOverallScoreRate(){
        let currentUserID = UserDefaults.standard.string(forKey: "currentUserUUID") ?? ""
        guard let userUUID = UUID(uuidString: currentUserID) else { return }
        var answers:[QuizAttempt]
        do {
            let predicate = #Predicate<QuizAttempt>{ attempt in
                attempt.profile?.id == userUUID
            }
            let descriptor = FetchDescriptor(predicate: predicate)
            answers = try modelContext.fetch(descriptor)
            answerCount = answers.count{$0.wasCorrect == true }
            totalCount = answers.count
        } catch  {
            print(error)
        }
        if (answerCount != 0 && totalCount != 0){
            overallScoreRate = Int(Double(answerCount)/Double(totalCount) * 100)
        }
    }
    
    func fetchRecentActivity(){
        
    }
}
