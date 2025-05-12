//
//  ItemsViewModel.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import Combine
import SwiftData

class ItemsViewModel: ObservableObject {
    @Published private(set) var items: [Item] = []
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchItems()
    }
    
    func fetchItems() {
        let descriptor = FetchDescriptor<Item>(sortBy: [SortDescriptor(\Item.timestamp, order: .reverse)])
        do {
            items = try modelContext.fetch(descriptor)
            print("Items fetched successfully.")
        } catch {
            print("Fetch failed: \(error.localizedDescription)")
            items = []
        }
    }

    func addItem(name: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Cannot add item with empty name.")
            return
        }
        let newItem = Item(name: name)
        modelContext.insert(newItem)
        print("Item '\(name)' inserted.")
        fetchItems()
    }

    func updateItem(item: Item, newName: String) {
        guard !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("Cannot update item with empty name.")
            return
        }
        item.name = newName
        item.timestamp = Date()
        print("Item updated to '\(newName)'.")
        fetchItems()
    }

    func deleteItems(at offsets: IndexSet) {
        let itemsToDelete = offsets.map { items[$0] }
        
        itemsToDelete.forEach { item in
            modelContext.delete(item)
            print("Item '\(item.name)' marked for deletion.")
        }
        fetchItems()
    }
    func saveContext() {
        do {
            try modelContext.save()
            print("Context saved successfully.")
        } catch {
            print("Failed to save context: \(error.localizedDescription)")
        }
    }
}
