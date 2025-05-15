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
    //    @Query(sort: \Profile.name) private var profiles: [Profile]
    
    @StateObject var homeViewModel: HomeViewModel
    @StateObject var categoryViewModel: CategoryViewModel
    
    @State private var showingAddProfileSheet = false
    @State private var navigationPath = NavigationPath()
    
    init(modelContext:ModelContext) {
        _homeViewModel = StateObject(wrappedValue: HomeViewModel(modelContext: modelContext.container.mainContext))
        _categoryViewModel = StateObject(wrappedValue: CategoryViewModel(modelContext: modelContext.container.mainContext))
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                let profileDescription: String = homeViewModel.profiles.isEmpty ? "Create Your Profile" : "Choose Your Profile"
                
                Text(profileDescription)
                    .font(.largeTitle)
                
                ScrollView(.horizontal) {
                    HStack(spacing: 20) {
                        ForEach(homeViewModel.profiles) { profile in
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
                .scrollIndicators(.hidden)
            }
            .sheet(isPresented: $showingAddProfileSheet) {
                AddProfileView()
                    .environmentObject(homeViewModel)
            }
            .navigationDestination(for: Profile.self) { profile in
                HomeView(profile: profile, navigationPath: $navigationPath)
                    .environmentObject(categoryViewModel)
            }
            .navigationDestination(for: QuizCategory.self) { category in
                QuizView(navigationPath: $navigationPath, category: category, difficulty: .level1)
            }
            .onAppear {
                homeViewModel.fetchProfile()
            }
            .onDisappear {
                homeViewModel.deleteProfile()
                //임시로 뷰가 사라지면 모든 프로필들이 지워지게 해놨습니다.
                //참고 부탁 드립니다.
            }
        }
    }
}

//#Preview {
//    let container = try! ModelContainer(for: Profile.self, configurations: .init(isStoredInMemoryOnly: true))
//    let sample = Profile(name: "민지", createdAt: .now, themeColorHex: "#e67e22")
//    container.mainContext.insert(sample)
//
//    return ChooseProfileView()
//        .modelContainer(container)
//}
