//
//  AddCategoryView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftUI
import SwiftData
import SFSymbolsPicker

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss

    @State private var categoryName: String = ""
    @State private var categoryIconName: String = ""
    @State private var categoryThemeColor: Color = .gray
    @State private var isPresented: Bool = false
    
    @EnvironmentObject private var categoryViewModel: CategoryViewModel

    var body: some View {
        NavigationStack {
            Form {
                TextField("카테고리 이름", text: $categoryName)
                Button {
                    isPresented = true
                } label: {
                    SymbolPicker(categoryIconName: $categoryIconName, isPresented: $isPresented)
                }
                .tint(.primary)
                ColorPicker("테마 색상 선택", selection: $categoryThemeColor, supportsOpacity: false)
            }
            .navigationTitle("카테고리 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveCategory()
                        dismiss()
                    }
                    .disabled(categoryName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveCategory() {
        let newCategory = QuizCategory(
            name: categoryName,
            iconName: categoryIconName.isEmpty ? nil : categoryIconName,
            themeColorHex: categoryThemeColor.hexStringWithAlpha
        )
        categoryViewModel.addCategory(newCategory)
    }
}

#Preview {
    AddCategoryView()
        .modelContainer(for: QuizCategory.self, inMemory: true)
}
