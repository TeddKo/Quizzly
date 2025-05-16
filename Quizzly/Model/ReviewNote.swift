//
//  ReviewNote.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class ReviewNote {
    var dateAdded: Date
    var userSelectedAnswerIndex: Int
    
    var profile: Profile?
    var quiz: Quiz?
    
    init(
        dateAdded: Date,
        userSelectedAnswerIndex: Int,
        profile: Profile,
        quiz: Quiz
    ) {
        self.dateAdded = dateAdded
        self.userSelectedAnswerIndex = userSelectedAnswerIndex
        self.profile = profile
        self.quiz = quiz
    }
}
