//
//  Profile.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class Profile {
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var iconName: String?
    var themeColorHex: String?
    
    @Relationship(deleteRule: .cascade, inverse: \QuizAttempt.profile)
    var attempts: [QuizAttempt]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \CategoryProgress.profile)
    var categoryProgresses: [CategoryProgress]? = []
    
    @Relationship(deleteRule: .cascade, inverse: \ReviewNote.profile)
    var reviewNotes: [ReviewNote]? = []
    
    init(
        id: UUID = UUID(),
        name: String,
        createdAt: Date,
        iconName: String? = nil,
        themeColorHex: String? = nil
    ) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
        self.iconName = iconName
        
        if let hex = themeColorHex {
            guard hex.isHexColor else {
                fatalError("Invalid hex color format")
            }
            self.themeColorHex = hex
        } else {
            self.themeColorHex = nil
        }
    }
}
