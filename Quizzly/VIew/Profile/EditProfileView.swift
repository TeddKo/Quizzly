//
//  EditProfileView.swift
//  Quizzly
//
//  Created by 강민지 on 5/16/25.
//

import SwiftUI
import SwiftData

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var homeViewModel: HomeViewModel

    @Bindable var profile: Profile
    
    @State private var color: Color = .white

    var onSave: (() -> Void)? = nil
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("프로필 이름 (Required)", text: $profile.name)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                ColorPicker("컬러를 선택하세요", selection: $color)
            }
            .navigationTitle("프로필 편집")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        saveChanges()
                        onSave?() 
                        dismiss()
                    }
                    .disabled(profile.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let hex = profile.themeColorHex {
                    color = colorFromHex(hex)
                }
            }

        }
    }

    private func saveChanges() {
        profile.themeColorHex = color.hexStringWithAlpha
    }
    
    private func colorFromHex(_ hex: String) -> Color {
        var hex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hex = hex.replacingOccurrences(of: "#", with: "")

        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        if hex.count == 6 {
            r = (int >> 16) & 0xff
            g = (int >> 8) & 0xff
            b = int & 0xff
        } else {
            // fallback to white if invalid
            return .white
        }

        return Color(red: Double(r) / 255, green: Double(g) / 255, blue: Double(b) / 255)
    }
}

#Preview {
    let profile = Profile(name: "미리보기", createdAt: .now, themeColorHex: "#FF9500")
    return EditProfileView(profile: profile)
}
