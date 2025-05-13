//
//  CreateQuzzView.swift
//  Quizzly
//
//  Created by 강민지 on 5/13/25.
//

//
//  CreateQuizView.swift
//  Quizzly
//
//  Created by 강민지 on 2025/05/13.
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
    
    // 전달된 카테고리 (실제 저장 시 연결용)
    var quizCategory: QuizCategory
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("문제 내용")) {
                    TextField("문제를 입력하세요", text: $questionDescription)
                }
                
                Section(header: Text("보기 (4개 입력)")) {
                    ForEach(0..<4, id: \.self) { index in
                        TextField("보기 \(index + 1)", text: $options[index])
                    }
                }
                
                Section(header: Text("정답 선택")) {
                    Picker("정답 보기", selection: $correctAnswerIndex) {
                        ForEach(0..<4, id: \.self) { index in
                            Text("보기 \(index + 1)").tag(index)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(header: Text("문제 해설 (선택)")) {
                    TextEditor(text: $explanation)
                        .frame(height: 100)
                }
                
                Section(header: Text("난이도 선택")) {
                    Picker("난이도", selection: $difficultyLevel) {
                        ForEach(DifficultyLevel.allCases, id: \.self) { level in
                            Text(level.displayName).tag(level)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    Color.clear
                        .frame(height: 80)
                        .listRowBackground(Color.clear)
                }
            }
            .background(Color(.clear))
            .navigationTitle("퀴즈 생성")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("저장") {
                        // TODO: 퀴즈 저장
                        
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }

        }
    }
    
    private var isFormValid: Bool {
        !questionDescription.isEmpty &&
        options.allSatisfy { !$0.isEmpty } &&
        options.indices.contains(correctAnswerIndex)
    }
}

#Preview {
    let sampleCategory = QuizCategory(
        name: "Swift",
        iconName: "swift",
        themeColorHex: "#FF5733"
    )
    
    return AddQuizView(quizCategory: sampleCategory)
}
