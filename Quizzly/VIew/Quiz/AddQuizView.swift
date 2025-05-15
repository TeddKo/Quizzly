//
//  AddQuizView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

import SwiftUI
import SwiftData

struct AddQuizView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var questionDescription: String = ""
    @State private var options: [String] = Array(repeating: "", count: 4)
    @State private var correctAnswerIndex: Int = 0
    @State private var explanation: String = ""
    @State private var difficultyLevel: DifficultyLevel = .level3
    @State private var imagePath: String? = nil
    
    @State private var selectedCategory: QuizCategory? = nil
    
    @Query(sort: \QuizCategory.name) private var categories: [QuizCategory]

    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 30) {
                AddQuizOriginalHeaderView(onSave: saveQuiz, onDismiss: { dismiss() }, isSaveEnabled: isFormValid())
                
                CategoryOriginalPickerView(selectedCategory: $selectedCategory, categories: categories, modelContext: modelContext)
                
                DifficultyOriginalPickerView(difficultyLevel: $difficultyLevel)
                
                QuestionOriginalInputView(questionDescription: $questionDescription)
                
                OptionsOriginalListView(options: $options, correctAnswerIndex: $correctAnswerIndex)
                
                ExplanationOriginalInputView(explanation: $explanation)
                
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
    }
    
    private func isFormValid() -> Bool {
        return selectedCategory != nil &&
               !questionDescription.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               options.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func saveQuiz() {
        guard let category = selectedCategory, isFormValid() else { return }
        
        let newQuiz = Quiz(
            questionDescription: questionDescription,
            options: options,
            correctAnswerIndex: correctAnswerIndex,
            explanation: explanation.isEmpty ? nil : explanation,
            difficultyLevel: difficultyLevel,
            quizCategory: category,
            imagePath: imagePath
        )
        
        modelContext.insert(newQuiz)
        dismiss()
    }
}

struct AddQuizOriginalHeaderView: View {
    var onSave: () -> Void
    var onDismiss: () -> Void
    var isSaveEnabled: Bool

    var body: some View {
        HStack {
            Text("퀴즈 생성")
                .font(.title2)
                .bold()
            
            Spacer()
            
            Button("저장") {
                onSave()
            }
            .fontWeight(.semibold)
            .disabled(!isSaveEnabled)
        }
    }
}

struct CategoryOriginalPickerView: View {
    @Binding var selectedCategory: QuizCategory?
    let categories: [QuizCategory]
    let modelContext: ModelContext

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("카테고리")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            Menu {
                Picker("카테고리", selection: $selectedCategory) {
                    Text("선택").tag(QuizCategory?.none)
                    ForEach(categories) { category in
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
    }
}

struct DifficultyOriginalPickerView: View {
    @Binding var difficultyLevel: DifficultyLevel

    var body: some View {
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
    }
}

struct QuestionOriginalInputView: View {
    @Binding var questionDescription: String

    var body: some View {
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
    }
}

struct OptionsOriginalListView: View {
    @Binding var options: [String]
    @Binding var correctAnswerIndex: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("선택지")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.black)
            
            ForEach(0..<4, id: \.self) { index in
                OptionOriginalInputRowView(
                    optionText: $options[index],
                    isCorrectAnswer: correctAnswerIndex == index,
                    optionLabel: Character(UnicodeScalar(65 + index)!).description,
                    index: index
                ) {
                    correctAnswerIndex = index
                }
            }
        }
    }
}

struct OptionOriginalInputRowView: View {
    @Binding var optionText: String
    var isCorrectAnswer: Bool
    let optionLabel: String
    let index: Int
    var onSelectAsCorrect: () -> Void

    var body: some View {
        HStack {
            Text(optionLabel)
                .font(.footnote)
                .fontWeight(.semibold)
                .foregroundColor(isCorrectAnswer ? .white : .black.opacity(0.5))
                .frame(width: 30, height: 30)
                .background(isCorrectAnswer ? .blue : .clear)
                .overlay(
                    Circle()
                        .stroke(isCorrectAnswer ? .blue : .gray.opacity(0.5), lineWidth: 2)
                )
                .clipShape(Circle())
            
            TextField("보기 \(index + 1)", text: $optionText)
                .padding(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isCorrectAnswer ? .green : Color.gray.opacity(0.5), lineWidth: isCorrectAnswer ? 2 : 1)
                )
            
            Spacer()
            
            if isCorrectAnswer {
                Image(systemName: "checkmark")
                    .foregroundColor(.green)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onSelectAsCorrect()
        }
    }
}

struct ExplanationOriginalInputView: View {
    @Binding var explanation: String

    var body: some View {
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
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: QuizCategory.self, Quiz.self, configurations: config)

    let sampleCategory1 = QuizCategory(name: "Sample Category 1")
    let sampleCategory2 = QuizCategory(name: "Sample Category 2")
    container.mainContext.insert(sampleCategory1)
    container.mainContext.insert(sampleCategory2)
    
    return AddQuizView()
        .modelContainer(container)
}
