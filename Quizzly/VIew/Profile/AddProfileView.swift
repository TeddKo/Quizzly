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
    @State private var color: Color = Color.dynamicBackground
    @EnvironmentObject var homeViewModel:HomeViewModel
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("프로필 이름 (Required)", text: $profileName)
                ColorPicker("컬러를 선택하세요", selection: $color)
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
            themeColorHex: color.hexStringWithAlpha
        )

        homeViewModel.addProfile(item: newProfile)
    }
}

#Preview {
    AddProfileView()
}
