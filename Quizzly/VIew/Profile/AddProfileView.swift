//
//  CreateProfileView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

struct AddProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var profileName: String = ""
    @State private var createdAt: Date = Date.now
    @State private var profileIconName: String = ""
    @State private var profileThemeColorHex: String = "#"

    var body: some View {
        NavigationStack {
            Form {
                TextField("프로필 이름 (Required)", text: $profileName)
                TextField("아이콘 이름 (e.g., swift, book.fill)", text: $profileIconName)
                TextField("컬러값 (e.g., #1ABC9C)", text: $profileThemeColorHex)
                    .autocapitalization(.none)
                    .keyboardType(.asciiCapable)
            }
            .navigationTitle("프로필 추가")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveProfile()
                        dismiss()
                    }
                    .disabled(profileName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func saveProfile() {
        let newProfile = Profile(
            name: profileName,
            createdAt: Date.now,
            iconName: profileIconName.isEmpty ? nil : profileIconName,
            themeColorHex: normalizeHexColor(profileThemeColorHex)
        )

        modelContext.insert(newProfile)
    }

    private func normalizeHexColor(_ hex: String) -> String? {
        let trimmedHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedHex.isEmpty || trimmedHex == "#" {
            return nil
        }
        return trimmedHex.hasPrefix("#") ? trimmedHex : "#" + trimmedHex
    }
}

#Preview {
    AddProfileView()
}
