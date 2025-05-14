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
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                
                backgroundView {
                    VStack(alignment: .leading, spacing: 15) {
                        
                        profileView(
                            name: profile.name,
                            themeColorHex: profile.themeColorHex
                        )
                        
                        totalCorrectRateView()
                        
                        recommendQuizView()
                    }
                }
                
                backgroundView {
                    categoryView(showingAllCategories: $showingAllCategories, allCategories: allCategories)
                }
                
                
                backgroundView {
                    recentQuizView(recentCards: recentCards)
                }
            }
            .padding()
        }
        .navigationTitle("홈")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .background(.gray.opacity(0.1))
    }
}

@ViewBuilder
private func profileView(name: String, themeColorHex: String?) -> some View {
    // MARK: 프로필 및 인사말
    HStack(spacing: 10) {
        Circle()
            .fill(themeColorHex?.asHexColor ?? .gray)
            .frame(width: 45, height: 45)
            .overlay {
                Text(name.prefix(1))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        
        VStack(alignment: .leading, spacing: 5) {
            Text("\(name)님, 안녕하세요!")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text("학습 계속해보세요")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.5))
        }
        
        Spacer()
    }
}

@ViewBuilder
private func totalCorrectRateView() -> some View {
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
}

@ViewBuilder
private func recommendQuizView() -> some View {
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

@ViewBuilder
private func backgroundView(@ViewBuilder content: () -> some View) -> some View {
    Group {
        content()
    }
    .padding()
    .background(.white)
    .cornerRadius(16)
    .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
}

@ViewBuilder
private func categoryView(
    showingAllCategories: Binding<Bool>,
    allCategories: [Category],
) -> some View {
    // MARK: 카테고리
    VStack(alignment: .leading, spacing: 10) {
        HStack {
            Text("카테고리")
                .font(.headline)
                .padding(.bottom, 10)
            
            Spacer()
            
            Button {
                withAnimation {
                    showingAllCategories.wrappedValue.toggle()
                }
            } label: {
                Text(showingAllCategories.wrappedValue ? "간단히 보기" : "모두 보기")
                .font(.footnote)
            }
        }
        
        let displayedCategories = showingAllCategories.wrappedValue ? allCategories : Array(allCategories.prefix(4))
        
        VStack {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(displayedCategories) { category in
                    CategoryCard(
                        title: category.title,
                        icon: category.icon,
                        count: category.count,
                        color: category.color
                    )
                }
            }
        }
    }
}

@ViewBuilder
private func recentQuizView(
    recentCards: [RecentCard]
) -> some View {
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

struct CategoryCard: View {
    let title: String
    let icon: String
    let count: Int
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .bold()
                
                Text("문제 \(count)개")
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
            
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .font(.title3)
                .foregroundColor(color)
                .padding(8)
                .cornerRadius(6)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.08))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.05), lineWidth: 2)
        )
        .cornerRadius(8)
    }
}

struct RecentCard: View, Identifiable, Hashable {
    let id = UUID()
    let title: String
    let percent: Double
    let date: String
    let isCorrect: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCorrect ? "checkmark.circle" : "xmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 15, height: 15)
                .fontWeight(.semibold)
                .foregroundColor(isCorrect ? .green : .red)
                .padding(8)
                .background(isCorrect ? .green.opacity(0.1) : .red.opacity(0.1))
                .cornerRadius(5)
                .padding(.leading, 10)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .bold()

                Text("\(Int(percent * 100))% 정답 · \(date)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            
            Spacer()
        }
    }
}

#Preview {
    HomeView(profile: Profile(name: "민지", createdAt: Date.now), navigationPath: .constant(NavigationPath()))
}
