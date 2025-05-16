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
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
}
