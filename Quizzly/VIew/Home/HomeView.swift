//
//  HomeView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI

struct HomeView: View {
    @Bindable var profile: Profile

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Hi, \(profile.name)")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        
                        Text("Find Deals")
                            .font(.largeTitle)
                            .bold()
                    }
                    
                    Spacer()
                    
                    Button {
                        
                    } label: {
                        ZStack {
                            Circle()
                                .fill(colorFromHex(profile.themeColorHex))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "person.fill")
                                .resizable()
                                .frame(width: 18, height: 18)
                                .foregroundStyle(.white)
                        }
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 15)
            }
            .padding()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        
                    } label: {
                        Image("menu")
                            .resizable()
                            .frame(width: 23, height: 23)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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

#Preview {
    HomeView(profile: Profile(name: "민지", createdAt: Date.now))
}
