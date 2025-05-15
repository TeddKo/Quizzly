//
//  CreateQuzzView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI
import SwiftData

struct AddQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    
    // TODO: Mock 상태이므로 SwiftData에 바인딩해야 함
    @State private var questionDescription: String = ""
    @State private var options: [String] = Array(repeating: "", count: 4)
    @State private var correctAnswerIndex: Int = 0
    @State private var explanation: String = ""
    @State private var difficultyLevel: DifficultyLevel = .level3
    @State private var imagePath: String? = nil
    
    @State private var selectedCategory: QuizCategory? = nil
    @EnvironmentObject var quizVieModel: QuizViewModel
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 30) {
                HStack {
                    Text("퀴즈 생성")
                        .font(.title2)
                        .bold()
                    
                    Spacer()
                    
                    Button("저장") {
                        saveQuiz()
                    }
                    .fontWeight(.semibold)
                }
                
                // MARK: 카테고리
                VStack(alignment: .leading, spacing: 6) {
                    Text("카테고리")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Menu {
                        Picker("카테고리", selection: $selectedCategory) {
                            Text("선택").tag(QuizCategory?.none)
                            
                            ForEach(try! modelContext.fetch(FetchDescriptor<QuizCategory>())) { category in
                                
                                Text(category.name).tag(QuizCategory?.some(category))
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory?.name ?? "선택")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)
                        }
                        .padding(10)
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                
                // MARK: 난이도
                VStack(alignment: .leading, spacing: 6) {
                    Text("난이도")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Picker("난이도", selection: $difficultyLevel) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text("\(level.rawValue)").tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                // MARK: 질문
                VStack(alignment: .leading, spacing: 6) {
                    Text("질문")
                        .font(.subheadline)
                        .foregroundColor(.black)
                    
                    TextEditor(text: $questionDescription)
                        .frame(height: 70)
                        .padding(10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }
                
                // MARK: 선택지
                VStack(alignment: .leading, spacing: 6) {
                    Text("선택지")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    ForEach(0..<4, id: \.self) { index in
                        HStack {
                            Text("\(Character(UnicodeScalar(65 + index)!))")
                                .font(.footnote)
                                .fontWeight(.semibold)
                                .foregroundColor(correctAnswerIndex == index ? .white : .black.opacity(0.5))
                                .frame(width: 30, height: 30)
                                .background(correctAnswerIndex == index ? .blue : .clear)
                                .overlay(
                                    Circle()
                                        .stroke(correctAnswerIndex == index ? .blue : .gray.opacity(0.5), lineWidth: 2)
                                )
                                .clipShape(Circle())
                            
                            TextField("보기 \(index + 1)", text: $options[index])
                                .padding(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(correctAnswerIndex == index ? .green : Color.gray.opacity(0.5), lineWidth: correctAnswerIndex == index ? 2 : 1)
                                )
                            
                            Spacer()
                            
                            if correctAnswerIndex == index {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            correctAnswerIndex = index
                        }
                    }
                }
                
                // MARK: 해설
                VStack(alignment: .leading, spacing: 6) {
                    Text("해설 (선택 사항)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    TextEditor(text: $explanation)
                        .frame(height: 50)
                        .padding(10)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                        )
                }
                
                Spacer()
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
        .padding(.top, 50)
        .ignoresSafeArea(edges: [.top, .bottom])
        .background(.gray.opacity(0.1))
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func saveQuiz() {
        guard let category = selectedCategory else { return }
        let newQuiz = Quiz(
            questionDescription: questionDescription,
            options: options,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation.isEmpty ? nil : explanation,
            difficultyLevel: difficultyLevel,
            quizCategory: category
        )
        
        quizVieModel.addQuiz(item: newQuiz)
        dismiss()
    }
}

#Preview {
//    AddQuizView()
}
