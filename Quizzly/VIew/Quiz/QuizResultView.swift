//
//  QuizResultView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI
import SwiftData // QuizCategory, Profile, Quiz가 @Model일 경우 필요

fileprivate struct QuizResultView_SummarySection: View {
    let quizTitle: String
    let scorePercentage: Int
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: String

    var body: some View {
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
                Circle().stroke(.gray.opacity(0.3), lineWidth: 20).frame(width: 110, height: 110)
                Circle().rotation(.degrees(-90)).trim(from: 0, to: CGFloat(scorePercentage) / 100).stroke(.blue, lineWidth: 20).frame(width: 110, height: 110)
                Text("\(scorePercentage)%").font(.title3).bold()
            }
            .clipShape(.circle)
            HStack(spacing: 24) {
                VStack {
                    Text("\(correctCount)").font(.title3).fontWeight(.bold).foregroundStyle(.green)
                    Text("정답").font(.footnote).fontWeight(.bold).foregroundStyle(.black.opacity(0.5))
                }
                VStack {
                    Text("\(incorrectCount)").font(.title3).fontWeight(.bold).foregroundStyle(.red)
                    Text("오답").font(.footnote).fontWeight(.bold).foregroundStyle(.black.opacity(0.5))
                }
                VStack {
                    Text(totalTime).font(.title3).fontWeight(.bold).foregroundStyle(.black)
                    Text("소요시간").font(.footnote).fontWeight(.bold).foregroundStyle(.black.opacity(0.5))
                }
            }
        }
    }
}

fileprivate struct QuizResultView_NotesSection: View {
    let notes: [QuizNote] // QuizNote는 일반 struct
    @Binding var navigationPath: NavigationPath

    var body: some View {
        if !notes.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("오답 노트").font(.headline).fontWeight(.semibold)
                ForEach(notes) { note in
                    Button { navigationPath.append(note) } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(note.question).font(.footnote).fontWeight(.semibold).foregroundColor(.black).multilineTextAlignment(.leading)
                            HStack(spacing: 15) {
                                Label("내 답안: \(note.userAnswer)", systemImage: "xmark.circle").font(.caption).fontWeight(.medium).foregroundColor(.red)
                                Label("정답: \(note.correctAnswer)", systemImage: "checkmark.circle").font(.caption).fontWeight(.medium).foregroundColor(.green)
                            }
                            Text(note.explanation).font(.caption2).fontWeight(.semibold).foregroundColor(.black.opacity(0.5)).lineLimit(2)
                        }
                        .padding(13).frame(maxWidth: .infinity, alignment: .leading).background(Color.red.opacity(0.06))
                        .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.red.opacity(0.1), lineWidth: 3))
                        .cornerRadius(12)
                    }
                }
            }
        }
    }
}

fileprivate struct QuizResultView_RecommendationsSection: View {
    let recommendations: [LearningRecommendation] // LearningRecommendation은 일반 struct

    var body: some View {
        if !recommendations.isEmpty {
            VStack(alignment: .leading, spacing: 13) {
                Text("추천 학습").font(.headline).padding(.bottom, 10)
                ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, item in
                    HStack {
                        Image(systemName: "book").resizable().scaledToFit().frame(width: 13, height: 13).fontWeight(.semibold).foregroundColor(.blue).padding(8).background(Color.blue.opacity(0.1)).cornerRadius(5)
                        VStack(alignment: .leading) {
                            Text(item.title).font(.footnote).fontWeight(.semibold)
                            Text(item.duration).font(.caption).fontWeight(.medium).foregroundColor(.black.opacity(0.5))
                        }
                    }
                    if index < recommendations.count - 1 { Divider() }
                }
            }
        }
    }
}

fileprivate struct QuizResultView_ActionButtonsSection: View {
    @Binding var navigationPath: NavigationPath
    @Binding var retry: Bool

    var body: some View {
        HStack {
            Button {
                if navigationPath.count > 1 { // Profile 외에 다른 것이 쌓여 있다면
                    navigationPath.removeLast(navigationPath.count - 1)
                }
            } label: {
                Text("홈으로").font(.subheadline).fontWeight(.semibold).foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity).padding(14).background(Color.gray.opacity(0.2)).cornerRadius(8)

            Button { retry = true } label: {
                Text("다시 풀기").font(.subheadline).fontWeight(.bold).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity).padding(14).background(Color.blue).foregroundColor(.white).cornerRadius(8)
        }
    }
}


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
            QuizResultView_SummarySection(
                quizTitle: quizTitle,
                scorePercentage: scorePercentage,
                correctCount: correctCount,
                incorrectCount: incorrectCount,
                totalTime: totalTime
            )

            QuizResultView_NotesSection(
                notes: notes,
                navigationPath: $navigationPath
            )

            QuizResultView_RecommendationsSection(
                recommendations: recommendations
            )

            QuizResultView_ActionButtonsSection(
                navigationPath: $navigationPath,
                retry: $retry
            )
        }
        .padding() // 원본 .padding() 유지
        .navigationBarBackButtonHidden(true) // 원본 .navigationBarBackButtonHidden(true) 유지
        .navigationDestination(isPresented: $retry) {
            QuizView( // QuizView는 QuizCategory @Model을 받을 수 있도록 정의되어야 함
                navigationPath: $navigationPath,
                category: category, // QuizCategory @Model 객체 전달
                difficulty: .level1 // 원본 로직 유지
            )
            // QuizView가 QuizViewModel을 @EnvironmentObject로 받는다면,
            // 이 QuizResultView를 포함하는 상위 View (보통 이전 QuizView)에서
            // QuizViewModel이 환경에 설정되어 있어야 합니다.
        }
        .navigationDestination(for: QuizNote.self) { selectedNote in // QuizNote는 일반 struct
            WrongNoteDetailView(note: selectedNote)
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

    init(id: UUID = UUID(), question: String, userAnswer: String, correctAnswer: String, explanation: String, level: String, category: String, dateAdded: String, choices: [Choice], recommendations: [LearningRecommendation], memo: String) {
        self.id = id; self.question = question; self.userAnswer = userAnswer; self.correctAnswer = correctAnswer; self.explanation = explanation; self.level = level; self.category = category; self.dateAdded = dateAdded; self.choices = choices; self.recommendations = recommendations; self.memo = memo
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
