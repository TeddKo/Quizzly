//
//  String.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftUI
import RegexBuilder

let hexColorRegex = Regex {
    Optionally("#")
    ChoiceOf {
        Repeat(.hexDigit, count: 6)
        Repeat(.hexDigit, count: 8)
    }
}

extension String {

    var isHexColor: Bool {
        if #available(iOS 16.0, *) {
            return self.wholeMatch(of: hexColorRegex) != nil
        } else {
            let pattern = "^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$"
            let range = NSRange(location: 0, length: self.utf16.count)
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return false }
            return regex.firstMatch(in: self, options: [], range: range) != nil
        }
    }

    var asHexColor: Color? {
        let hex = self.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

        guard hex.count == 6 || hex.count == 8 else {
            return nil
        }

        var hexValue: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&hexValue) else {
            return nil
        }

        let red, green, blue, alpha: Double

        if hex.count == 6 {
            red   = Double((hexValue & 0xFF0000) >> 16) / 255.0
            green = Double((hexValue & 0x00FF00) >> 8)  / 255.0
            blue  = Double( hexValue & 0x0000FF)        / 255.0
            alpha = 1.0
        } else {
            alpha = Double((hexValue & 0xFF000000) >> 24) / 255.0
            red   = Double((hexValue & 0x00FF0000) >> 16) / 255.0
            green = Double((hexValue & 0x0000FF00) >> 8)  / 255.0
            blue  = Double( hexValue & 0x000000FF)        / 255.0
        }

        return Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
