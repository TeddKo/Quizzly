//
//  CategoryProgress.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class CategoryProgress {
    var totalAttempts: Int = 0
    var correctAttempts: Int = 0
    var lastAttemptedAt: Date?
    
    var profile: Profile?
    var quizCategory: QuizCategory?
    
    init(
        totalAttempts: Int = 0,
        correctAttempts: Int = 0,
        lastAttemptedAt: Date? = nil,
        profile: Profile?,
        category: QuizCategory?
    ) {
        self.totalAttempts = totalAttempts
        self.correctAttempts = correctAttempts
        self.lastAttemptedAt = lastAttemptedAt
        self.profile = profile
        self.quizCategory = category
    }
    
    var correctRate: Double {
        guard totalAttempts > 0 else { return 0.0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }
}
