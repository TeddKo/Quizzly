//
//  Quiz.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

enum DifficultyLevel: Int, Codable, CaseIterable, Comparable {
    case level1 = 1
    case level2 = 2
    case level3 = 3
    case level4 = 4
    case level5 = 5
    
    var id: Int { self.rawValue }
    
    var displayName: String {
        switch self {
        case .level1:
            "매우 쉬움"
        case .level2:
            "쉬움"
        case .level3:
            "보통"
        case .level4:
            "어려움"
        case .level5:
            "매우 어려움"
        }
    }

    public static func < (lhs: DifficultyLevel, rhs: DifficultyLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

@Model
final class Quiz {
    @Attribute(.unique) var id: UUID
    var questionDescription: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String?
    var difficultyLevel: DifficultyLevel
    var imagePath: String?
    
    var quizCategory: QuizCategory?
    
    init(
        id: UUID = UUID(),
        questionDescription: String,
        options: [String],
        correctAnswerIndex: Int,
        explanation: String? = nil,
        difficultyLevel: DifficultyLevel,
        quizCategory: QuizCategory,
        imagePath: String? = nil,
    ) {
        guard !options.isEmpty else {
            fatalError("Quiz options cannot be empty.")
        }
        
        guard options.indices.contains(correctAnswerIndex) else {
            fatalError("correctAnswerIndex is out of bounds for options.")
        }
        
        self.id = id
        self.questionDescription = questionDescription
        self.options = options
        self.correctAnswerIndex = correctAnswerIndex
        self.explanation = explanation
        self.difficultyLevel = difficultyLevel
        self.quizCategory = quizCategory
        self.imagePath = imagePath
    }
}
