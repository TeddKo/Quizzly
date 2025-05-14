//
//  Color.swift
//  Quizzly
//
//  Created by Ko Minhyuk on 5/12/25.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 13.0, *)
extension Color {

    var hexString: String? {
        let uiColor = UIColor(self)

        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let rInt = Int(red * 255.0)
        let gInt = Int(green * 255.0)
        let bInt = Int(blue * 255.0)

        let hexString = String(format: "#%02X%02X%02X", rInt, gInt, bInt)

        return hexString
    }

    var hexStringWithAlpha: String? {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        let aInt = Int(alpha * 255.0)
        let rInt = Int(red * 255.0)
        let gInt = Int(green * 255.0)
        let bInt = Int(blue * 255.0)

        let hexString = String(format: "#%02X%02X%02X%02X", aInt, rInt, gInt, bInt)

        return hexString
    }
}
