//
//  CreateProfileView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

struct ChooseProfileView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Profile.name) private var profiles: [Profile]
    
    @State private var showingAddProfileSheet = false
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                let profileDescription: String = profiles.isEmpty ? "Create Your Profile" : "Choose Your Profile"
                
                Text(profileDescription)
                    .font(.largeTitle)
                
                HStack(spacing: 20) {
                    ForEach(profiles) { profile in
                        Button {
                            navigationPath.append(profile)
                        } label: {
                            ProfileCardView(profile: profile)
                        }
                    }
                    
                    VStack {
                        Button {
                            showingAddProfileSheet = true
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(.gray.opacity(0.5))
                                    .frame(width: 50, height: 50)
                                
                                Image(systemName: "plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 18, height: 18)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                        }
                        
                        Text("add")
                            .opacity(0)
                            .font(.caption)
                    }
                    .shadow(color: .gray.opacity(0.3), radius: 7, x: 0, y: 3)
                }
                .padding(.top, 40)
            }
            .sheet(isPresented: $showingAddProfileSheet) {
                AddProfileView()
            }
            .navigationDestination(for: Profile.self) { profile in
                HomeView(profile: profile, navigationPath: $navigationPath)
            }
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: Profile.self, configurations: .init(isStoredInMemoryOnly: true))
    let sample = Profile(name: "민지", createdAt: .now, iconName: "person.crop.circle", themeColorHex: "#e67e22")
    container.mainContext.insert(sample)
    
    return ChooseProfileView()
        .modelContainer(container)
}
