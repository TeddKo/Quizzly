//
//  WrongNoteDetailView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

// MARK: - Main View: WrongNoteDetailView
struct WrongNoteDetailView: View {
    let note: QuizNote
    @Environment(\.dismiss) var dismiss
    @State private var memoText: String

    // "다시 풀기" 버튼을 눌렀을 때 호출될 클로저
    var onRetryQuiz: (QuizNote) -> Void

    init(note: QuizNote, onRetryQuiz: @escaping (QuizNote) -> Void) {
        self.note = note
        self._memoText = State(initialValue: note.memo)
        self.onRetryQuiz = onRetryQuiz
        
        // 디버깅 로그 (필요시 사용)
        // print("✅ WrongNoteDetailView init: Question: \(note.question), OriginalQuizID: \(String(describing: note.originalQuizID))")
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
                        onRetryQuiz(note) // 클로저 호출
                        dismiss()         // 시트 닫기
                    }
                )
            }
            .padding()
        }
        .navigationBarHidden(true) // 시트 내부이므로 네비게이션 바는 NavigationStack이 관리
        .onAppear {
            // print("🧭 WrongNoteDetailView loaded for question: \(note.question)")
        }
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

// MARK: - Sub-component: NoteProblemInfoSection
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
        .background(Color.red.opacity(0.06))
        .cornerRadius(8)
    }
}

// MARK: - Sub-component: NoteChoicesSection
fileprivate struct NoteChoicesSection: View {
    let choices: [Choice]
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

// MARK: - Sub-component: ChoiceRow
fileprivate struct ChoiceRow: View {
    let choice: Choice
    let isUserAnswer: Bool
    let isCorrectAnswer: Bool

    private var backgroundColor: Color {
        if isCorrectAnswer { return .green }
        if isUserAnswer { return .red }
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

// MARK: - Sub-component: NoteExplanationSection
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

// MARK: - Sub-component: NoteRecommendationsSection
fileprivate struct NoteRecommendationsSection: View {
    let recommendations: [LearningRecommendation]

    var body: some View {
        if !recommendations.isEmpty {
            VStack(alignment: .leading, spacing: 13) {
                Text("관련 학습 자료")
                    .font(.headline)
                    .padding(.bottom, 10)

                ForEach(Array(recommendations.enumerated()), id: \.1.id) { index, rec in
                    HStack {
                        Image(systemName: "book")
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
}

// MARK: - Sub-component: NoteMemoSection
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

// MARK: - Sub-component: NoteActionButtons
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
// 샘플 데이터 정의 (QuizNote, Choice, LearningRecommendation extension)
// 이 extension들은 WrongNoteDetailView.swift 파일 하단 또는 공통 모델 파일에 위치할 수 있습니다.
// 여기서는 Preview를 위해 이 파일에 함께 둡니다.
extension Choice {
    static var sampleA_preview: Choice { Choice(label: "A", text: "미리보기 보기 A (정답)") }
    static var sampleB_preview: Choice { Choice(label: "B", text: "미리보기 보기 B (오답)") }
    static var sampleC_preview: Choice { Choice(label: "C", text: "미리보기 보기 C") }
    static var sampleD_preview: Choice { Choice(label: "D", text: "미리보기 보기 D") }
}

extension LearningRecommendation {
    static var sampleRec1_preview: LearningRecommendation { LearningRecommendation(id: UUID(), title: "미리보기 개념 학습", duration: "10분") }
    static var sampleRec2_preview: LearningRecommendation { LearningRecommendation(id: UUID(), title: "미리보기 유사 문제", duration: "5분") }
}

extension QuizNote {
    static var sampleForDetailPreview: QuizNote {
        QuizNote(
            id: UUID(),
            originalQuizID: UUID(), // 샘플 원본 퀴즈 ID
            question: "미리보기: SwiftUI에서 @State는 무엇인가요?",
            userAnswer: Choice.sampleB_preview.text,
            correctAnswer: Choice.sampleA_preview.text,
            explanation: "미리보기: @State는 SwiftUI 뷰의 로컬 상태를 저장하는 프로퍼티 래퍼입니다.",
            level: "쉬움",
            category: "SwiftUI",
            dateAdded: "2025년 5월 17일",
            choices: [Choice.sampleA_preview, Choice.sampleB_preview, Choice.sampleC_preview, Choice.sampleD_preview],
            recommendations: [LearningRecommendation.sampleRec1_preview, LearningRecommendation.sampleRec2_preview],
            memo: "미리보기 메모입니다."
        )
    }
}

#Preview {
    NavigationStack {
        WrongNoteDetailView(
            note: QuizNote.sampleForDetailPreview, // 수정된 샘플 데이터 사용
            onRetryQuiz: { note in
                print("Preview: Retry quiz for note: \(note.question)")
            }
        )
    }
}
