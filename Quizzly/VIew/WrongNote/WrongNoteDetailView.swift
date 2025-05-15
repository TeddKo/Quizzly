//
//  WrongNoteDetailView.swift
//  Quizzly
//
//  Created by 강민지 on 5/14/25.
//

import SwiftUI

struct WrongAnswerDetailView: View {
    let note: QuizNote
    @State private var memoText: String = ""
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {

                HStack {
                    Button {
                        
                    } label: {
                        Image(systemName: "chevron.left")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 13, height: 13)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                            .padding(8)
                            .overlay(
                                Circle()
                                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                            )
                            .clipShape(Circle())
                    }
                    
                    Text("오답노트 상세")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                }

                // MARK: 문제 제목
                VStack {
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
                    
                    // MARK: 선택지
                    VStack(spacing: 10) {
                        ForEach(note.choices, id: \.label) { choice in
                            HStack {
                                Text(choice.label)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .frame(width: 20, height: 20)
                                    .background(
                                        Circle()
                                            .fill(
                                                choice.text == note.correctAnswer ? .green :
                                                choice.text == note.userAnswer ? .red :
                                                        .clear
                                            )
                                    )
                                    .foregroundColor(
                                        choice.text == note.correctAnswer ? .white :
                                        choice.text == note.userAnswer ? .white :
                                        .primary
                                    )
                                    .overlay(
                                        Circle()
                                            .stroke(
                                                choice.text == note.correctAnswer ? .green :
                                                choice.text == note.userAnswer ? .red :
                                                .gray.opacity(0.6),
                                                lineWidth: 1
                                            )
                                    )
                                
                                Text(choice.text)
                                    .font(.subheadline)
                                
                                Spacer()
                            }
                            .padding(13)
                            .background(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(choice.text == note.userAnswer ? .red :
                                            choice.text == note.correctAnswer ? .green :
                                            .gray.opacity(0.5),
                                            lineWidth: 3)
                            )
                            .cornerRadius(8)
                        }
                    }
                    
                    // MARK: 해설
                    VStack(alignment: .leading, spacing: 10) {
                        Text("해설")
                            .font(.footnote)
                            .fontWeight(.semibold)
                        
                        Text(note.explanation)
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
                .padding(13)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.red.opacity(0.06))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.red.opacity(0.06), lineWidth: 3)
                )
                .cornerRadius(8)

                // MARK: 관련 학습 자료
                VStack(alignment: .leading, spacing: 13) {
                    Text("관련 학습 자료")
                        .font(.headline)
                        .padding(.bottom, 10)

                    ForEach(Array(note.recommendations.enumerated()), id: \.1.id) { index, rec in
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
                                Text(rec.title).bold()
                                    .font(.footnote)
                                    .fontWeight(.semibold)
                                
                                Text(rec.duration)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .foregroundColor(.black.opacity(0.5))
                            }
                        }
                        
                        
                        if index < note.recommendations.count - 1 {
                            Divider()
                        }
                    }
                }

                // MARK: 메모
                VStack(alignment: .leading, spacing: 8) {
                    Text("내 메모")
                        .font(.headline)

                    TextEditor(text: .constant(note.memo))
                        .frame(height: 80)
                        .padding(10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }

                HStack {
                    Button {

                    } label: {
                        Text("목록으로")
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
//        .onAppear {
//            print(note)
//        }
        .onAppear {
            memoText = note.memo
        }
        .onAppear {
            print("🧭 WrongAnswerDetailView loaded")
            print("📌 note.question:", note.question)
        }

    }
}

//#Preview {
//    WrongAnswerDetailView(note:
//        QuizNote(
//            question: "TCP와 UDP의 차이점으로 올바르지 않은 것은?",
//            userAnswer: "C",
//            correctAnswer: "D",
//            explanation: "TCP는 혼잡 제어 기능을 제공하지만, UDP는 제공하지 않습니다.",
//            level: "Level 4 (어려움)",
//            category: "네트워크",
//            dateAdded: "2025년 5월 14일 추가됨",
//            choices: [
//                .init(label: "A", text: "TCP는 연결 지향적이고, UDP는 비연결 지향적이다."),
//                .init(label: "B", text: "TCP는 신뢰성 있는 데이터 전송을 보장하고, UDP는 그렇지 않다."),
//                .init(label: "C", text: "TCP와 UDP 모두 혼잡 제어 기능을 제공한다."),
//                .init(label: "D", text: "UDP는 TCP보다 일반적으로 더 빠르다.")
//            ],
//            recommendations: [
//                .init(title: "TCP와 UDP의 비교 및 활용", duration: "15분 학습코스"),
//                .init(title: "네트워크 프로토콜의 이해", duration: "8분 비디오")
//            ],
//            memo: "TCP는 혼잡 제어, 흐름 제어, 오류 제어를 모두 제공하지만 UDP는 이런 기능들이 없다. 대신 UDP가 더 빠르고 오버헤드가 적다."
//        )
//    )
//}
