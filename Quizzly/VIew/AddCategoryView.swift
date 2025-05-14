//
//  AddCategoryView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftUI
import SwiftData

struct AddCategoryView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var categoryViewModel:CategoryViewModel

    @State private var categoryName: String = ""
    @State private var categoryIconName: String = ""
    @State private var categoryThemeColorHex: String = "#"

    var body: some View {
        NavigationStack {
            Form {
                TextField("카테고리 이름 (Required)", text: $categoryName)
                TextField("아이콘 이름 (e.g., swift, book.fill)", text: $categoryIconName)
                TextField("컬러값 (e.g., #1ABC9C)", text: $categoryThemeColorHex)
                    .autocapitalization(.none)
                    .keyboardType(.asciiCapable)
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
            themeColorHex: normalizeHexColor(categoryThemeColorHex)
        )
        categoryViewModel.addCategory(item: newCategory)
    }

    private func normalizeHexColor(_ hex: String) -> String? {
        let trimmedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedHex.isEmpty || trimmedHex == "#" {
            return nil
        }
        return trimmedHex.hasPrefix("#") ? trimmedHex : "#" + trimmedHex
    }
}
