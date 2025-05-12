//
//  EditCategoryView.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import SwiftUI
import SwiftData

struct EditCategoryView: View {
    @Bindable var category: QuizCategory
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("카테고리 상세")) {
                TextField("카테고리 이름 (Required)", text: $category.name)

                TextField("아이콘 이름 (e.g., swift, book.fill)", text: Binding(
                    get: { category.iconName ?? "" },
                    set: { category.iconName = $0.isEmpty ? nil : $0 }
                ))

                TextField("컬러값 (e.g., #1ABC9C)", text: Binding(
                    get: { category.themeColorHex ?? "" },
                    set: { category.themeColorHex = normalizeHexColor($0) }
                ))
                .autocapitalization(.none)
                .keyboardType(.asciiCapable)
            }
        }
        .navigationTitle("카테고리 편집")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("확인") {
                    dismiss()
                }
            }
        }
    }
    
    private func normalizeHexColor(_ hex: String) -> String? {
        let trimmedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedHex.isEmpty || trimmedHex == "#" {
            return nil
        }
        return trimmedHex.hasPrefix("#") ? trimmedHex : "#" + trimmedHex
    }
}
