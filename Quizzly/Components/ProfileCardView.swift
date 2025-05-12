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
                    .fill(profile.themeColorHex?.asHexColor ?? .gray)
                    .frame(width: 50, height: 50)
                
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(profile.themeColorHex?.asHexColor == .white ? .black : .white)
            }
            .shadow(color: .gray.opacity(0.3), radius: 7, x: 0, y: 3)
            
            Text(profile.name)
                .font(.caption)
                .foregroundStyle(.black)
        }
    }
}
