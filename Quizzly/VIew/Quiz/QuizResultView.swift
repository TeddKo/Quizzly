//
//  QuizResultView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

struct QuizResultView: View {
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: String
    let scorePercentage: Int
    let quizTitle: String
    let notes: [QuizNote]
    let recommendations: [LearningRecommendation]

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
                    VStack(alignment: .leading, spacing: 7) {
                        Text(note.question)
                            .font(.footnote)
                            .fontWeight(.semibold)

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
    }
}

// MARK: - Supporting Models
struct QuizNote: Identifiable {
    let id = UUID()
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let explanation: String
}

struct LearningRecommendation: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let duration: String
}

// MARK: - Preview
struct QuizResultView_Previews: PreviewProvider {
    static var previews: some View {
        QuizResultView(
            correctCount: 8,
            incorrectCount: 2,
            totalTime: "03:24",
            scorePercentage: 80,
            quizTitle: "Swift 기초 퀴즈",
            notes: [
                QuizNote(
                    question: "SwiftUI에서 상태(State) 변수를 선언하는 올바른 방법은?",
                    userAnswer: "B",
                    correctAnswer: "A",
                    explanation: "'@state'가 아닌 '@State'로 대문자 S를 사용해야 합니다."
                ),
                QuizNote(
                    question: "다음 중 Swift의 옵셔널 언래핑 방법이 아닌 것은?",
                    userAnswer: "C",
                    correctAnswer: "D",
                    explanation: "optional.unwrap() 메서드는 존재하지 않습니다."
                )
            ],
            recommendations: [
                LearningRecommendation(title: "SwiftUI 프로퍼티 래퍼 심화", duration: "10분 학습코스"),
                LearningRecommendation(title: "Swift 옵셔널 마스터하기", duration: "15분 학습코스")
            ]
        )
    }
}
