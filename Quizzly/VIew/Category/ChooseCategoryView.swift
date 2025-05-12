//
//  ChooseCategoryView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI
import SwiftData

let mockCategories: [QuizCategory] = [
    QuizCategory(name: "iOS", iconName: "iphone", themeColorHex: "#34C759"),
    QuizCategory(name: "Design", iconName: "scribble", themeColorHex: "#FF9500"),
    QuizCategory(name: "CS", iconName: "cpu", themeColorHex: "#007AFF"),
    QuizCategory(name: "Swift", iconName: "swift", themeColorHex: "#AF52DE")
]

struct ChooseCategoryView: View {
    @State private var selectedDifficulty: DifficultyLevel = .level3
    
    let categories: [QuizCategory]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(categories, id: \.id) { category in
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(alignment: .top) {
                                Image(systemName: category.iconName ?? "questionmark.circle")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .foregroundColor(colorFromHex(category.themeColorHex))
                                    .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                                
                                Spacer()
                            }
                            .padding(.bottom)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(category.name)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                
                                Text("\(category.quizzes?.count ?? 0) questions")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .padding(.vertical, 16)
                        .frame(maxWidth: .infinity)
                        .background(.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("난이도를 선택하세요")
                        .font(.headline)
                    
                    Picker("난이도", selection: $selectedDifficulty) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button {
                    
                } label: {
                    Text("퀴즈 풀기")
                        .tint(.white)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.cyan)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .foregroundStyle(.cyan)
                        .offset(y: 10)
                        .opacity(0.4)
                        .blur(radius: 12)
                }
            }
            .padding(.horizontal)
            .padding(.top, 25)
            .padding(.bottom, 15)
            .navigationTitle("카테고리 선택")
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

#Preview {
    ChooseCategoryView(categories: mockCategories)
}
