//
//  Item.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var id: UUID
    var timestamp: Date
    var name: String

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        name: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.name = name
    }
}
