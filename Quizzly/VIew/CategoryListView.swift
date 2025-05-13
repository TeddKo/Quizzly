//
//  ContentView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftData
import SwiftUI

struct CategoryListView: View {

    @Environment(\.modelContext) private var modelContext
    //    @Query(sort: \QuizCategory.name) private var quizCategories: [QuizCategory]
    @State private var showingAddCategorySheet = false
    @StateObject private var viewModel: CategoryViewModel

    init(modelContext: ModelContext) {
        _viewModel = StateObject(wrappedValue: CategoryViewModel(modelContext: modelContext.container.mainContext))
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.quizCategories) { category in
                    NavigationLink(value: category) {
                        HStack {
                            //                            if let iconName = quiz.iconName, !iconName.isEmpty {
                            //                                Image(systemName: iconName)
                            //                                    .foregroundColor(colorFromHex(quiz.themeColorHex))
                            //                            } else {
                            //                                Image(systemName: "folder")
                            //                                    .foregroundColor(colorFromHex(quiz.themeColorHex))
                            //                            }
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
                AddCategoryView(viewModel: viewModel)
            }

            .navigationDestination(for: QuizCategory.self) { category in
                EditCategoryView(category: category, viewModel: viewModel)
            }
            .onAppear {
                viewModel.fetchCategory()
            }
        }
    }

    private func deleteCategories(offsets: IndexSet) {
            try? offsets.map{viewModel.quizCategories[$0]}.forEach(viewModel.deleteCategory)
//        withAnimation {
//            var testStatement = offsets.map { viewModel.quizs[$0] }.forEach(modelContext.delete)
//        }
    }

    private func colorFromHex(_ hexString: String?) -> Color {
        guard let hex = hexString?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted), hex.count == 6 else {
            return Color.gray
        }
        var rgbValue: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&rgbValue)

        return Color(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0
        )
    }
}

//#Preview {
//    do{
//        try? CategoryListView(modelContext: ModelContext(ModelContainer(for: Quiz.self)))
//    } catch let e{
//        print(e)
//    }
//}
