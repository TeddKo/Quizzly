//
//  HomeView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI

struct HomeView: View {
    @Bindable var profile: Profile
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
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
                    navigationPath = NavigationPath()
                } label: {
                    ZStack {
                        Circle()
                            .fill(profile.themeColorHex?.asHexColor ?? .gray)
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
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView(profile: Profile(name: "민지", createdAt: Date.now), navigationPath: .constant(NavigationPath()))
}
