//
//  String.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation

private let hexColorRegex = /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{8})$/

extension String {
    var isHexColor: Bool {
        return self.wholeMatch(of: hexColorRegex) != nil
    }
}
