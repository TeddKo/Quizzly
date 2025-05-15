//
//  QuizResultView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

struct QuizResultView: View {
    @Binding var navigationPath: NavigationPath
    
    @State private var retry: Bool = false
    
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: String
    let scorePercentage: Int
    let quizTitle: String
    let notes: [QuizNote]
    let recommendations: [LearningRecommendation]
    let category: QuizCategory
    
    var body: some View {
        VStack(spacing: 24) {
            // MARK: 타이틀 및 링
            VStack(spacing: 10) {
                Text("퀴즈 결과")
                    .font(.title2)
                    .bold()

                Text(quizTitle)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }

            VStack(spacing: 15) {
                ZStack {
                    Circle()
                        .stroke(.gray.opacity(0.3), lineWidth: 20)
                        .frame(width: 110, height: 110)

                    Circle()
                        .rotation(.degrees(-90))
                        .trim(from: 0, to: CGFloat(scorePercentage) / 100)
                        .stroke(.blue, lineWidth: 20)
                        .frame(width: 110, height: 110)

                    Text("\(scorePercentage)%")
                        .font(.title3)
                        .bold()
                }
                .clipShape(.circle)
            
                HStack(spacing: 24) {
                    VStack {
                        Text("\(correctCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.green)
                        
                        Text("정답")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    
                    VStack {
                        Text("\(incorrectCount)")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.red)
                        
                        Text("오답")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    
                    VStack {
                        Text(totalTime)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.black)
                        
                        Text("소요시간")
                            .font(.footnote)
                            .fontWeight(.bold)
                            .foregroundStyle(.black.opacity(0.5))
                    }
                }
            }

            // MARK: 오답 노트
            VStack(alignment: .leading, spacing: 16) {
                Text("오답 노트")
                    .font(.headline)
                    .fontWeight(.semibold)

                ForEach(notes) { note in
                    Button {
                        navigationPath.append(note)
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(note.question)
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                                .multilineTextAlignment(.leading)
                            
                            HStack(spacing: 15) {
                                Label("내 답안: \(note.userAnswer)", systemImage: "xmark.circle")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.red)
                                
                                Label("정답: \(note.correctAnswer)", systemImage: "checkmark.circle")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                            
                            Text(note.explanation)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.black.opacity(0.5))
                        }
                        .padding(13)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.red.opacity(0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.red.opacity(0.1), lineWidth: 3)
                        )
                        .cornerRadius(12)
                    }
                }
            }

            // MARK: 추천 학습
            VStack(alignment: .leading, spacing: 13) {
                Text("추천 학습")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, item in
                    HStack {
                        Image(systemName: "book")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                            .padding(8)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(5)
                        
                        VStack(alignment: .leading) {
                            Text(item.title)
                                .font(.footnote)
                                .fontWeight(.semibold)
                            
                            Text(item.duration)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.black.opacity(0.5))
                        }
                    }
                    
                    if index < recommendations.count - 1 {
                        Divider()
                    }
                }
            }

            HStack {
                Button {
                    navigationPath.removeLast(1)
                } label: {
                    Text("홈으로")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.black)
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)

                Button {
                    retry = true
                } label: {
                    Text("다시 풀기")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .navigationDestination(isPresented: $retry) {
            QuizView(
                navigationPath: $navigationPath,
                category: category,
                difficulty: .level1
            )
        }
        .navigationDestination(for: QuizNote.self) { selectedNote in
            WrongAnswerDetailView(note: selectedNote)
        }
    }
}

struct QuizNote: Identifiable, Hashable {
    let id: UUID
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let explanation: String
    let level: String
    let category: String
    let dateAdded: String
    let choices: [Choice]
    let recommendations: [LearningRecommendation]
    let memo: String

    // 명시적 init 필요
    init(
        id: UUID = UUID(),
        question: String,
        userAnswer: String,
        correctAnswer: String,
        explanation: String,
        level: String,
        category: String,
        dateAdded: String,
        choices: [Choice],
        recommendations: [LearningRecommendation],
        memo: String
    ) {
        self.id = id
        self.question = question
        self.userAnswer = userAnswer
        self.correctAnswer = correctAnswer
        self.explanation = explanation
        self.level = level
        self.category = category
        self.dateAdded = dateAdded
        self.choices = choices
        self.recommendations = recommendations
        self.memo = memo
    }
}

struct Choice: Hashable, Codable {
    let label: String
    let text: String
}

struct LearningRecommendation: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let duration: String
}

