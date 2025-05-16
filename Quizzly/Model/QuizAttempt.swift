//
//  QuestionAttempt.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class QuizAttempt {
    var attemptDate: Date
    var selectedAnswerIndex: Int
    var wasCorrect: Bool
    var timeTaken: Double?
    
    var profile: Profile?
    var quiz: Quiz?
    
    init(
        attemptDate: Date,
        selectedAnswerIndex: Int,
        wasCorrect: Bool,
        timeTaken: Double? = nil,
        profile: Profile,
        quiz: Quiz
    ) {
        self.attemptDate = attemptDate
        self.selectedAnswerIndex = selectedAnswerIndex
        self.wasCorrect = wasCorrect
        self.timeTaken = timeTaken
        self.profile = profile
        self.quiz = quiz
    }
}
