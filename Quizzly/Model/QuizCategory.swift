//
//  QuizCategory.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class QuizCategory {
    @Attribute(.unique) var id: UUID
    var name: String
    var iconName: String?
    var themeColorHex: String?
    
    @Relationship(inverse: \Quiz.quizCategory)
    var quizzes: [Quiz]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \CategoryProgress.quizCategory)
    var progressEntries: [CategoryProgress]? = []
    
    init(
        id: UUID = UUID(),
        name: String,
        iconName: String? = nil,
        themeColorHex: String? = nil
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.themeColorHex = themeColorHex
    }
}
