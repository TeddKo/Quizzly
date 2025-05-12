//
//  ProfileCardView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI

struct ProfileCardView: View {
    let profile: Profile
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(colorFromHex(profile.themeColorHex))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(colorFromHex(profile.themeColorHex) == .white ? .black : .white)
            }
            .shadow(color: .gray.opacity(0.3), radius: 7, x: 0, y: 3)
            
            Text(profile.name)
                .font(.caption)
                .foregroundStyle(.black)
        }
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
