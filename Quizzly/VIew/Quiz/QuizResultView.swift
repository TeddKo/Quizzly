//
//  QuizResultView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI
import SwiftData

// MARK: - Summary Section (변경 없음)
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
                .foregroundColor(Color.primary.opacity(0.5))
        }
        VStack(spacing: 15) {
            ZStack {
                Circle().stroke(.secondary.opacity(0.3), lineWidth: 20).frame(width: 110, height: 110)
                Circle().rotation(.degrees(-90)).trim(from: 0, to: CGFloat(scorePercentage) / 100).stroke(Color.adaptiveBlue, lineWidth: 20).frame(width: 110, height: 110)
                Text("\(scorePercentage)%").font(.title3).bold()
            }
            .clipShape(.circle)
            HStack(spacing: 24) {
                VStack { Text("\(correctCount)").font(.title3).fontWeight(.bold).foregroundStyle(Color.adaptiveGreen); Text("정답").font(.footnote).fontWeight(.bold).foregroundStyle(Color.adaptiveGrayOverlay) }
                VStack { Text("\(incorrectCount)").font(.title3).fontWeight(.bold).foregroundStyle(Color.adaptiveRed); Text("오답").font(.footnote).fontWeight(.bold).foregroundStyle(Color.adaptiveGrayOverlay) }
                VStack { Text(totalTime).font(.title3).fontWeight(.bold).foregroundStyle(Color.primary); Text("소요시간").font(.footnote).fontWeight(.bold).foregroundStyle(Color.adaptiveGrayOverlay) }
            }
        }
    }
}

// MARK: - Notes Section
fileprivate struct QuizResultView_NotesSection: View {
    let notes: [QuizNote]
    var onNoteTap: (QuizNote) -> Void // 부모에게 알릴 클로저

    var body: some View {
        if !notes.isEmpty {
            VStack(alignment: .leading, spacing: 16) {
                Text("오답 노트").font(.headline).fontWeight(.semibold)
                ForEach(notes) { note in
                    Button {
                        onNoteTap(note) // 클로저 호출
                    } label: {
                        VStack(alignment: .leading, spacing: 7) {
                            Text(note.question).font(.footnote).fontWeight(.semibold).foregroundColor(Color.primary).multilineTextAlignment(.leading)
                            HStack(spacing: 15) {
                                Label("내 답안: \(note.userAnswer)", systemImage: "xmark.circle").font(.caption).fontWeight(.medium).foregroundColor(Color.adaptiveRed)
                                Label("정답: \(note.correctAnswer)", systemImage: "checkmark.circle").font(.caption).fontWeight(.medium).foregroundColor(Color.adaptiveGreen)
                            }
                            Text(note.explanation).font(.caption2).fontWeight(.semibold).foregroundColor(Color.adaptiveGrayOverlay).lineLimit(2)
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

// MARK: - Recommendations Section (변경 없음)
fileprivate struct QuizResultView_RecommendationsSection: View {
    let recommendations: [LearningRecommendation]

    var body: some View {
        if !recommendations.isEmpty {
            VStack(alignment: .leading, spacing: 13) {
                Text("추천 학습").font(.headline).padding(.bottom, 10)
                ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, item in
                    HStack {
                        Image(systemName: "book").resizable().scaledToFit().frame(width: 13, height: 13).fontWeight(.semibold).foregroundColor(Color.adaptiveBlue).padding(8).background(Color.adaptiveBlue.opacity(0.1)).cornerRadius(5)
                        VStack(alignment: .leading) { Text(item.title).font(.footnote).fontWeight(.semibold); Text(item.duration).font(.caption).fontWeight(.medium).foregroundColor(Color.adaptiveGrayOverlay) }
                    }
                    if index < recommendations.count - 1 { Divider() }
                }
            }
        }
    }
}

// MARK: - Action Buttons Section
fileprivate struct QuizResultView_ActionButtonsSection: View {
    @Binding var navigationPath: NavigationPath
    @Binding var retryTrigger: Bool // 변수명 변경 (더 명확하게)

    var body: some View {
        HStack {
            Button {
                if navigationPath.count > 1 {
                    navigationPath.removeLast(navigationPath.count - 1)
                } else if !navigationPath.isEmpty {
                     navigationPath.removeLast()
                 }
            } label: {
                Text("홈으로").font(.subheadline).fontWeight(.semibold).foregroundStyle(Color.primary)
            }
            .frame(maxWidth: .infinity).padding(14).background(Color.secondary.opacity(0.2)).cornerRadius(8)

            Button { retryTrigger = true } label: { // 이 버튼은 "전체 다시 풀기" 역할
                Text("다시 풀기").font(.subheadline).fontWeight(.bold).foregroundStyle(Color.dynamicBackground)
            }
            .frame(maxWidth: .infinity).padding(14).background(Color.adaptiveBlue).foregroundColor(Color.dynamicBackground).cornerRadius(8)
        }
    }
}

// MARK: - Main QuizResultView
struct QuizResultView: View {
    @Binding var navigationPath: NavigationPath
    @State private var retryTrigger: Bool = false // 네비게이션 트리거 (전체 또는 특정 카테고리)
    
    let correctCount: Int
    let incorrectCount: Int
    let totalTime: String
    let scorePercentage: Int
    let quizTitle: String
    let notes: [QuizNote]
    let recommendations: [LearningRecommendation]
    let currentCategory: QuizCategory // 현재 퀴즈의 카테고리 (전체 다시 풀기 시 사용)
    
    @State private var noteForItemSheet: QuizNote?
    
    @State private var categoryForRetry: QuizCategory? // 오답노트에서 다시 풀기 시 사용할 카테고리
    @State private var difficultyForRetry: DifficultyLevel = .level1 // 오답노트에서 다시 풀기 시 사용할 난이도

    @Environment(\.modelContext) private var modelContext

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
                onNoteTap: { tappedNote in
                    self.noteForItemSheet = tappedNote
                }
            )

            QuizResultView_RecommendationsSection(
                recommendations: recommendations
            )

            QuizResultView_ActionButtonsSection(
                navigationPath: $navigationPath,
                retryTrigger: $retryTrigger
            )
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .sheet(item: $noteForItemSheet) { selectedNoteInSheet in
            NavigationStack {
                WrongNoteDetailView(
                    note: selectedNoteInSheet,
                    onRetryQuiz: { noteToRetry in
                        // 1. QuizNote에서 카테고리 이름과 난이도 이름 가져오기
                        let categoryName = noteToRetry.category
                        let difficultyName = noteToRetry.level

                        // 2. 카테고리 이름으로 QuizCategory 객체 찾기
                        if let fetchedCategory = fetchCategoryByName(name: categoryName) {
                            self.categoryForRetry = fetchedCategory
                            
                            // 3. 난이도 이름으로 DifficultyLevel enum 값 찾기
                            if let fetchedDifficulty = DifficultyLevel(displayName: difficultyName) {
                                self.difficultyForRetry = fetchedDifficulty
                            } else {
                                print("Warning: Could not parse difficulty: \(difficultyName) from QuizNote. Using default difficulty .level1 for retry.")
                                self.difficultyForRetry = .level1
                            }
                            
                            // 4. 네비게이션 트리거
                            self.retryTrigger = true
                            
                            print("Attempting to retry quiz. Category: '\(self.categoryForRetry?.name ?? "N/A")', Difficulty: '\(self.difficultyForRetry.displayName)'")
                        } else {
                            print("Error: Category '\(categoryName)' not found for retrying quiz.")
                            // 필요하다면 사용자에게 알림 표시
                        }
                    }
                )
            }
        }
        .navigationDestination(isPresented: $retryTrigger) {
            QuizView(
                navigationPath: $navigationPath,
                // 오답노트에서 "다시 풀기"를 한 경우 categoryForRetry 사용,
                // 그렇지 않으면 (전체 다시 풀기) currentCategory 사용
                category: categoryForRetry ?? currentCategory,
                // 오답노트에서 "다시 풀기"를 한 경우 difficultyForRetry 사용,
                // 전체 다시 풀기의 경우, 현재 QuizResultView가 생성될 때 사용된 difficulty를 사용하거나
                // 사용자가 선택하게 해야 함. 여기서는 difficultyForRetry를 우선 사용.
                // 만약 categoryForRetry가 nil이면 (즉, 전체 다시 풀기면)
                // 현재 currentCategory의 기본 난이도(예: .level1) 또는 이전 퀴즈의 난이도를 사용해야 함.
                // 여기서는 오답노트에서 설정된 difficultyForRetry를 사용하고,
                // 전체 다시풀기 시에는 .level1을 기본값으로 가정 (QuizView 생성 시 difficulty 파라미터 참고).
                // 이 부분은 전체 다시 풀기 시 어떤 난이도로 할지에 대한 정책이 필요합니다.
                // 여기서는 오답노트에서 온 경우 설정된 값을, 아니면 .level1을 사용하도록 함.
                difficulty: categoryForRetry != nil ? difficultyForRetry : .level1 // <<-- 이 부분은 앱의 정책에 맞게 수정 필요
            )
            .onAppear {
                // QuizView가 나타난 후, 다음 "전체 다시 풀기"를 위해 초기화
                self.categoryForRetry = nil
                self.difficultyForRetry = .level1 // 기본값으로 리셋
            }
        }
        // .navigationDestination(for: QuizNote.self) { ... } // 시트를 사용하므로 이젠 불필요
    }

    private func fetchCategoryByName(name: String) -> QuizCategory? {
        let predicate = #Predicate<QuizCategory> { $0.name == name }
        var descriptor = FetchDescriptor(predicate: predicate)
        descriptor.fetchLimit = 1
        do {
            return try modelContext.fetch(descriptor).first
        } catch {
            print("Failed to fetch category by name '\(name)': \(error)")
            return nil
        }
    }
}

// QuizNote 구조체 (originalQuizID 추가)
struct QuizNote: Identifiable, Hashable {
    let id: UUID
    let originalQuizID: UUID? // 원본 Quiz의 ID (QuizView에서 채워줘야 함)
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let explanation: String
    let level: String // DifficultyLevel의 displayName
    let category: String // QuizCategory의 name
    let dateAdded: String
    let choices: [Choice]
    let recommendations: [LearningRecommendation]
    let memo: String

    init(id: UUID = UUID(), originalQuizID: UUID?, question: String, userAnswer: String, correctAnswer: String, explanation: String, level: String, category: String, dateAdded: String, choices: [Choice], recommendations: [LearningRecommendation], memo: String) {
        self.id = id
        self.originalQuizID = originalQuizID
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

// Choice 구조체 (변경 없음)
struct Choice: Hashable, Codable {
    let label: String
    let text: String
}

// LearningRecommendation 구조체 (변경 없음)
struct LearningRecommendation: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let duration: String
}

// DifficultyLevel 확장 (예: Quiz.swift 파일 하단 또는 Models.swift)
// enum DifficultyLevel 정의는 Quiz.swift에 이미 있다고 가정합니다.
extension DifficultyLevel {
    init?(displayName: String) {
        for levelCase in DifficultyLevel.allCases {
            if levelCase.displayName == displayName {
                self = levelCase
                return
            }
        }
        return nil
    }
}
