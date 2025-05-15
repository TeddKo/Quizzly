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
    
    static var dynamicBackground: Color {
        Color(UIColor.systemBackground)
    }
    
    static var adaptiveGrayOverlay: Color {
        Color(uiColor: UIColor { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                return UIColor(white: 1.0, alpha: 0.1) // 밝은 회색 느낌
            default:
                return UIColor.black.withAlphaComponent(0.05)
            }
        })
    }
    
    static var adaptiveCyan: Color {
        Color(uiColor: UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
                ? UIColor(red: 0.4, green: 1.0, blue: 1.0, alpha: 1.0)  // 다크모드용
                : UIColor.systemTeal  // 라이트모드용
        })
    }
    
    static var adaptiveGreen: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 0.6, green: 1.0, blue: 0.6, alpha: 1.0)
                : UIColor.systemGreen
        })
    }

    static var adaptiveRed: Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(red: 1.0, green: 0.5, blue: 0.5, alpha: 1.0)
                : UIColor.systemRed
        })
    }
    
    static var adaptiveBlue: Color {
        Color(uiColor: UIColor { trait in
            switch trait.userInterfaceStyle {
            case .dark:
                return UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1.0) // 밝은 하늘색
            default:
                return .systemBlue
            }
        })
    }
}
