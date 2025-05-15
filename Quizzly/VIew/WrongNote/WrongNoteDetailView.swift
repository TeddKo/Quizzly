//
//  WrongNoteDetailView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

// MARK: - Main View: WrongNoteDetailView
struct WrongNoteDetailView: View {
    let note: QuizNote // 이전과 동일
    @Environment(\.dismiss) var dismiss

    // 메모는 이 View 내에서 State로 관리하고,
    // 실제 저장은 ViewModel을 통하거나 .onDisappear에서 처리 필요
    @State private var memoText: String

    // ViewModel 주입 (메모 저장, 다시 풀기 기능 등을 위해 추후 필요)
    // @EnvironmentObject var noteViewModel: NoteViewModel // 예시

    init(note: QuizNote) {
        self.note = note
        _memoText = State(initialValue: note.memo) // State 초기화
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                NoteDetailHeaderView(title: "오답노트 상세") {
                    dismiss()
                }

                NoteProblemInfoSection(note: note)

                NoteChoicesSection(choices: note.choices, userAnswer: note.userAnswer, correctAnswer: note.correctAnswer)
                
                NoteExplanationSection(explanation: note.explanation)

                if !note.recommendations.isEmpty {
                    NoteRecommendationsSection(recommendations: note.recommendations)
                }

                NoteMemoSection(memoText: $memoText)

                NoteActionButtons(
                    onDismiss: { dismiss() },
                    onRetry: {
                        // TODO: "다시 풀기" 기능 구현
                        print("다시 풀기 버튼 탭됨 - 기능 구현 필요. Quiz ID 또는 정보: \(note.question)")
                        // 예: 특정 퀴즈로 돌아가는 로직 (navigationPath 또는 ViewModel 사용)
                    }
                )
            }
            .padding()
        }
        .navigationBarHidden(true) // 헤더를 커스텀하게 사용하므로 네비게이션 바 숨김
        .onAppear {
            // memoText는 init에서 이미 초기화됨
            print("🧭 WrongNoteDetailView loaded for question: \(note.question)")
        }
        // .onDisappear {
        //     // TODO: memoText가 변경되었으면 저장하는 로직 (ViewModel 또는 modelContext 사용)
        //     if memoText != note.memo {
        //         print("메모가 변경되었습니다. 저장 로직 필요: \(memoText)")
        //         // 예: noteViewModel.updateMemo(for: note.id, newMemo: memoText)
        //     }
        // }
    }
}

// MARK: - Sub-component: NoteDetailHeaderView
fileprivate struct NoteDetailHeaderView: View {
    let title: String
    var onDismiss: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 13, height: 13)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(8)
                    .overlay(Circle().stroke(.gray.opacity(0.5), lineWidth: 2))
                    .clipShape(Circle())
            }
            
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            
            Spacer()
        }
    }
}

// MARK: - Sub-component: NoteProblemInfoSection (문제 기본 정보)
fileprivate struct NoteProblemInfoSection: View {
    let note: QuizNote

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(note.category)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .foregroundColor(.red)
                    .clipShape(Capsule())
                
                Spacer()
                
                Text(note.dateAdded)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.black.opacity(0.5))
            }
            Text(note.question)
                .font(.headline)
                .bold()
            
            Text("난이도: \(note.level)")
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(.black.opacity(0.5))
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.06)) // 전체 박스 배경
        .cornerRadius(8)
    }
}

// MARK: - Sub-component: NoteChoicesSection (선택지)
fileprivate struct NoteChoicesSection: View {
    let choices: [Choice] // QuizNote.Choice
    let userAnswer: String
    let correctAnswer: String

    var body: some View {
        VStack(spacing: 10) {
            ForEach(choices, id: \.label) { choice in
                ChoiceRow(
                    choice: choice,
                    isUserAnswer: choice.text == userAnswer,
                    isCorrectAnswer: choice.text == correctAnswer
                )
            }
        }
    }
}

fileprivate struct ChoiceRow: View {
    let choice: Choice
    let isUserAnswer: Bool
    let isCorrectAnswer: Bool

    private var backgroundColor: Color {
        if isCorrectAnswer { return .green }
        if isUserAnswer { return .red } // isCorrectAnswer가 false일 때만 빨간색 (틀린 답)
        return .clear
    }

    private var foregroundColor: Color {
        if isCorrectAnswer || isUserAnswer { return .white }
        return .primary
    }
    
    private var strokeColor: Color {
        if isCorrectAnswer { return .green }
        if isUserAnswer { return .red }
        return .gray.opacity(0.5)
    }

    var body: some View {
        HStack {
            Text(choice.label)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 20, height: 20)
                .background(Circle().fill(backgroundColor))
                .foregroundColor(foregroundColor)
                .overlay(Circle().stroke(strokeColor, lineWidth: 1))
            
            Text(choice.text)
                .font(.subheadline)
            
            Spacer()
        }
        .padding(13)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(strokeColor, lineWidth: 3)
        )
        .cornerRadius(8)
    }
}


// MARK: - Sub-component: NoteExplanationSection (해설)
fileprivate struct NoteExplanationSection: View {
    let explanation: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("해설")
                .font(.footnote)
                .fontWeight(.semibold)
            
            Text(explanation)
                .font(.footnote)
        }
        .padding(13)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(.gray.opacity(0.2), lineWidth: 3)
        )
        .cornerRadius(8)
    }
}


// MARK: - Sub-component: NoteRecommendationsSection (추천 학습)
fileprivate struct NoteRecommendationsSection: View {
    let recommendations: [LearningRecommendation] // QuizNote.LearningRecommendation

    var body: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("관련 학습 자료")
                .font(.headline)
                .padding(.bottom, 10)

            ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, rec in
                HStack {
                    Image(systemName: "book") // 아이콘 고정 또는 rec에서 받기
                        .resizable().scaledToFit().frame(width: 13, height: 13)
                        .fontWeight(.semibold).foregroundColor(.blue)
                        .padding(8).background(Color.blue.opacity(0.1)).cornerRadius(5)
                    
                    VStack(alignment: .leading) {
                        Text(rec.title).bold()
                            .font(.footnote)
                            .fontWeight(.semibold)
                        Text(rec.duration)
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
    }
}

// MARK: - Sub-component: NoteMemoSection (메모)
fileprivate struct NoteMemoSection: View {
    @Binding var memoText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("내 메모")
                .font(.headline)

            TextEditor(text: $memoText)
                .frame(height: 80)
                .padding(10)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                )
        }
    }
}

// MARK: - Sub-component: NoteActionButtons (하단 버튼)
fileprivate struct NoteActionButtons: View {
    var onDismiss: () -> Void
    var onRetry: () -> Void

    var body: some View {
        HStack {
            Button(action: onDismiss) {
                Text("목록으로")
                    .font(.subheadline).fontWeight(.semibold).foregroundStyle(.black)
            }
            .frame(maxWidth: .infinity).padding(14)
            .background(Color.gray.opacity(0.2)).cornerRadius(8)

            Button(action: onRetry) {
                Text("다시 풀기")
                    .font(.subheadline).fontWeight(.bold).foregroundStyle(.white)
            }
            .frame(maxWidth: .infinity).padding(14)
            .background(Color.blue).foregroundColor(.white).cornerRadius(8)
        }
    }
}

// MARK: - Preview
// QuizNote와 하위 struct들에 대한 샘플 데이터 정의 필요
extension Choice { // QuizResultView.swift에 정의된 Choice 사용 가정
    static let sampleA = Choice(label: "A", text: "보기 A 텍스트 (정답)")
    static let sampleB = Choice(label: "B", text: "보기 B 텍스트 (사용자 오답)")
    static let sampleC = Choice(label: "C", text: "보기 C 텍스트")
    static let sampleD = Choice(label: "D", text: "보기 D 텍스트")
}

extension LearningRecommendation { // QuizResultView.swift에 정의된 LearningRecommendation 사용 가정
    static let sampleRec1 = LearningRecommendation(id: UUID(), title: "관련 개념 학습하기", duration: "15분 코스")
    static let sampleRec2 = LearningRecommendation(id: UUID(), title: "유사 문제 더 풀어보기", duration: "10분 퀴즈")
}

extension QuizNote { // QuizResultView.swift에 정의된 QuizNote 사용 가정
    static var sampleForDetail: QuizNote {
        QuizNote(
            id: UUID(),
            question: "SwiftUI에서 View를 업데이트하는 가장 기본적인 방법은 무엇인가요? 그리고 왜 그런가요?",
            userAnswer: Choice.sampleB.text, // 사용자가 선택한 오답 텍스트
            correctAnswer: Choice.sampleA.text, // 정답 텍스트
            explanation: "SwiftUI는 선언적 프로그래밍 패러다임을 따르며, @State, @Binding, @ObservedObject, @EnvironmentObject, @StateObject와 같은 프로퍼티 래퍼를 사용하여 데이터의 변경을 감지하고 자동으로 View를 다시 렌더링합니다. 그 중 @State가 가장 기본적인 값 타입 상태 관리 도구입니다.",
            level: "보통",
            category: "SwiftUI 기초",
            dateAdded: "2025년 5월 16일",
            choices: [Choice.sampleA, Choice.sampleB, Choice.sampleC, Choice.sampleD],
            recommendations: [LearningRecommendation.sampleRec1, LearningRecommendation.sampleRec2],
            memo: "State와 ObservableObject의 차이를 명확히 이해하자."
        )
    }
}

#Preview {
    // DetailView는 NavigationStack 내에서 테스트하는 것이 좋습니다.
    NavigationStack {
        WrongNoteDetailView(note: QuizNote.sampleForDetail)
            // .environmentObject(NoteViewModel(modelContext: ...)) // ViewModel 필요시 주입
    }
}
