//
//  HomeView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI

let recentCards: [RecentCard] = [
    RecentCard(title: "Swift 기초 문법", percent: 0.9, date: "오늘", isCorrect: true),
    RecentCard(title: "데이터베이스 개념", percent: 0.6, date: "어제", isCorrect: false)
]

struct Category: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let icon: String
    let count: Int
    let color: Color
}

let allCategories: [Category] = [
    Category(title: "자료구조", icon: "doc.on.clipboard", count: 32, color: .purple),
    Category(title: "운영체제", icon: "cpu", count: 25, color: .green),
    Category(title: "Swift", icon: "chevron.left.slash.chevron.right", count: 48, color: .blue),
    Category(title: "네트워크", icon: "arrow.left.arrow.right", count: 36, color: .red),
    Category(title: "자료구조", icon: "doc.on.clipboard", count: 32, color: .purple), // ← OK now
    Category(title: "운영체제", icon: "cpu", count: 25, color: .green),
    Category(title: "Swift", icon: "chevron.left.slash.chevron.right", count: 48, color: .blue),
    Category(title: "네트워크", icon: "arrow.left.arrow.right", count: 36, color: .red)
]

struct HomeView: View {
    @Bindable var profile: Profile
    @Binding var navigationPath: NavigationPath
    
    @State private var showingAllCategories = false
    @EnvironmentObject var categoryViewModel:CategoryViewModel
    @AppStorage("currentUserUUID") var id = ""
    var userID:String
//    var allCategories:[QuizCategory]
    @State var categories:[QuizCategory] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                Group {
                    VStack(alignment: .leading, spacing: 15) {
                        // MARK: 프로필 및 인사말
                        HStack(spacing: 10) {
                            Circle()
                                .fill(profile.themeColorHex?.asHexColor ?? .gray)
                                .frame(width: 45, height: 45)
                                .overlay {
                                    Text(profile.name.prefix(1))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    navigationPath = NavigationPath()
                                }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text("\(profile.name)님, 안녕하세요!")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                
                                Text("학습 계속해보세요")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            
                            Spacer()
                        }
                        .onAppear {
                            id = userID
                        }
                        
                        // MARK: 전체 정답률
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("전체 정답률")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black.opacity(0.5))
                                
                                // TODO: 실제 퍼센트로 수정
                                Text("78%")
                                    .font(.title3)
                                    .bold()
                            }
                            
                            Spacer()
                            
                            ZStack {
                                Circle()
                                    .stroke(.gray.opacity(0.3), lineWidth: 10)
                                    .frame(width: 55, height: 55)
                                
                                Circle()
                                    .rotation(.degrees(-90))
                                    .trim(from: 0, to: 0.78)
                                    .stroke(.blue, style: .init(lineWidth: 10, lineCap: .round))
                                    .frame(width: 55, height: 55)
                            }
                            .clipShape(.circle)
                        }
                        .padding(13)
                        .background(.blue.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.blue.opacity(0.05), lineWidth: 1)
                        )
                        .cornerRadius(8)
                        
                        // MARK: 추천 퀴즈
                        Text("추천 퀴즈")
                            .font(.headline)
                        
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("알고리즘 기초 퀴즈")
                                    .fontWeight(.semibold)
                                
                                Text("취약점 보완 추천")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black.opacity(0.5))
                            }
                            
                            Spacer()
                            
                            Button {
                                
                            }label: {
                                Text("시작")
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.orange.opacity(0.8))
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(13)
                        .background(.yellow.opacity(0.09))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.orange.opacity(0.1), lineWidth: 1)
                        )
                        .cornerRadius(8)
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                
                Group {
                    // MARK: 카테고리
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("카테고리")
                                .font(.headline)
                                .padding(.bottom, 10)
                            
                            Spacer()
                            
                            Button {
                                withAnimation {
                                    showingAllCategories.toggle()
                                }
                            } label: {
                                Text(showingAllCategories ? "간단히 보기" : "모두 보기")
                                .font(.footnote)
                            }
                        }
                        
//                        let displayedCategories = showingAllCategories ? allCategories : Array(allCategories.prefix(4))
//                        let displayedCategories = showingAllCategories ? categories : Array(categories.prefix(4))
                        
                        VStack {
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(categories) { category in
//                                    Button {
//                                        navigationPath.append(category)
//                                    } label: {
//                                        CategoryCard(
//                                            title: category.title,
//                                            icon: category.icon,
//                                            count: category.count,
//                                            color: category.color
//                                        )
//                                    }
                                    Button {
                                        navigationPath.append(category)
                                        print(#line,#file,"test")
                                    } label: {
                                        Text(category.name)
                                        Image(systemName: category.iconName ?? "")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                            .font(.title3)
                                            .foregroundColor(.primary)
                                            .padding(8)
                                            .cornerRadius(6)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                .onAppear {
                    categories = categoryViewModel.getCategories()
                }
                
                Group {
                    // MARK: 최근 학습
                    VStack(alignment: .leading, spacing: 13) {
                        Text("최근 학습")
                            .font(.headline)
                            .padding(.bottom, 10)
                        
                        ForEach(Array(recentCards.enumerated()), id: \.1.id) { index, card in
                            VStack {
                                RecentCard(
                                    title: card.title,
                                    percent: card.percent,
                                    date: card.date,
                                    isCorrect: card.isCorrect
                                )
                            }

                            if index < recentCards.count - 1 {
                                Divider()
                            }
                        }
                    }
                }
                .padding()
                .background(.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .background(.gray.opacity(0.1))
    }
}






#Preview {
//    HomeView(profile: Profile(name: "민지", createdAt: Date.now), navigationPath: .constant(NavigationPath()), userID: ""), allCategoreis: []
}
