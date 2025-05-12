//
//  ContentView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftUI
import SwiftData

struct CategoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \QuizCategory.name) private var quizCategories: [QuizCategory]
    @State private var showingAddCategorySheet = false
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(quizCategories) { category in
                    NavigationLink(value: category) {
                        HStack {
                            if let iconName = category.iconName, !iconName.isEmpty {
                                Image(systemName: iconName)
                                    .foregroundColor(category.themeColorHex?.asHexColor)
                            } else {
                                Image(systemName: "folder")
                                    .foregroundColor(category.themeColorHex?.asHexColor)
                            }
                            Text(category.name)
                        }
                    }
                }
                .onDelete(perform: deleteCategories)
            }
            .navigationTitle("카테고리")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddCategorySheet = true
                    } label: {
                        Label("카테고리 추가", systemImage: "plus.circle.fill")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            }
            
            .sheet(isPresented: $showingAddCategorySheet) {
                AddCategoryView()
            }
            
            .navigationDestination(for: QuizCategory.self) { category in
                EditCategoryView(category: category)
            }
        }
    }
    
    private func deleteCategories(offsets: IndexSet) {
        withAnimation {
            offsets.map { quizCategories[$0] }.forEach(modelContext.delete)
        }
    }
}

#Preview {
    CategoryListView()
        .modelContainer(for: QuizCategory.self, inMemory: true)
}
