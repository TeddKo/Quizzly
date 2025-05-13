//
//  QuizzView.swift
//  Quizzly
//
//  Created by 강민지 on 5/12/25.
//

import SwiftUI
import SwiftData

struct QuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var ratio: CGFloat = 0.5
    @State private var selectedOption: String? = nil
    
    @Query(sort: \Quiz.questionDescription) private var quizzes: [Quiz]
    
    let category: QuizCategory
    let difficulty: DifficultyLevel
    
    // TODO: mock 데이터 실제 데이터로 바꾸기
    let mockOptions = [
        "Volleyball",
        "Football",
        "Basketball",
        "Badminton"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.gray.opacity(0.5))
                        .frame(maxWidth: .infinity, maxHeight: 200)
                        .overlay {
                            Text("What is the most popular sport throughout the world?")
                                .bold()
                                .foregroundStyle(.black)
                                .multilineTextAlignment(.center)
                        }
                }
                
                VStack(spacing: 12) {
                    ForEach(mockOptions, id: \.self) { option in
                        Button {
                            selectedOption = option
                        } label: {
                            Text(option)
                                .bold()
                                .foregroundStyle(selectedOption == option ? .cyan : .black)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedOption == option ? Color.cyan : Color.gray.opacity(0.5),
                                    lineWidth: 2
                                )
                        )
                    }
                }
                
                Button {
                    
                } label: {
                    Text("Next")
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .bold()
                            .foregroundColor(.black)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(.black.opacity(0.5), lineWidth: 1.3)
                            )
                    }
                }
            }
        }
    }
}

#Preview {
    let sampleCategory = QuizCategory(
        name: "Swift",
        iconName: "swift",
        themeColorHex: "#FF5733"
    )

    QuizView(category: sampleCategory, difficulty: DifficultyLevel.level1)
}
