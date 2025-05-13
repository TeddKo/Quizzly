//
//  ViewModel.swift
//  Quizzly
//
//  Created by DEV on 5/12/25.
//

import Combine
import Foundation
import SwiftData
import SwiftUI

class ViewModel: ObservableObject {

    @Published var quizs: [Quiz] = []
    @Published var quizCategories: [QuizCategory] = []
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchQuiz()
    }

    //TODO: - CRUD (quizs)
    func addQuiz(item: Quiz) {
        modelContext.insert(item)
        fetchQuiz()
        print(#line, "add called")
    }  //C

    func fetchQuiz() {
        let descriptor = FetchDescriptor<Quiz>()
        do {
            quizs = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            quizs = []
        }
    }

    //TODO: - CRUD (category)
    func addCategory(item: QuizCategory) {
        modelContext.insert(item)
        fetchCategory()
        print(#line, "add called")
    }  //C

    func fetchCategory() {
        let descriptor = FetchDescriptor<QuizCategory>()
        do {
            quizCategories = try modelContext.fetch(descriptor)
        } catch {
            print("Fetch failed: \(error)")
            quizCategories = []
        }
    }

    func updateCategory(name: String, category: QuizCategory) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        category.name = name
        fetchCategory()
    }

    func deleteCategory(item: QuizCategory) {
        modelContext.delete(item)
        fetchCategory()
        print(#file, #line, "del called")
    }

    func editQuiz() {}  // U
    func deleteQuiz() {}  //D

    func addProfile() {}
    //TODO: -

    /*
     QuizAttempt의 wasCorrect가 true인게 많은걸 카테고리별로 카운팅해서
     제일 높은 카테고리의 학습을 추천학습으로 보여주면  될것 같고요
     오답노트는 푼 문제중에 틀린걸 오답노트로 나열해서 보여주면 될것 같네요
     그런데 비교할만큼 데이터가 쌓이지 않았다면
     그냥 안보여주고 넘어가고 충분히 데이터가 쌓였을때 노출시키는걸로  하면 될것 같아요
     비교할만한 데이터가 결국 있어야 하니깐요
     내가 iOS카테고리 10문제만 풀고 6개를 맞았는데 추천학습은 못보여주죠 점수랑 오답노트는 보여줄 수 있지만요
     추천학습만 카테고리별로 QuizAttempt 값이 충분히 쌓였을때 보여주면 될 것같아요
     */

    //추천학습
    //#1.wasCorrect가 false인 것듯을 카운팅
    //#2.가장 많은 것을 추천학습으로 표현
    //
    //오답노트
    //#1.틀린 문제들을 정렬해서 오답노트라고 다시 보여줌
    //

    func filteredQuizByLevel(level: Int) {
        let predicate = #Predicate<Quiz> { quizs in
            quizs.difficultyLevel.rawValue > level
        }
        let discriptor = FetchDescriptor<Quiz>(predicate: predicate)
        do {
            quizs = try modelContext.fetch(discriptor)
        } catch {
            print("Error")
        }
    }

    func filteredQuizByCategory(category: String) {
        let predicate = #Predicate<Quiz> { quizs in
            quizs.quizCategory?.name.contains(category) ?? false
        }
        do {
            quizs = try quizs.filter(predicate)
        } catch {
            print("error")
        }
    }
}
