//
//  Color+Dynamic.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.01.2025.
//

import SwiftUI

extension Color {

    init(light: UIColor, dark: UIColor) {
        let uiColor = UIColor { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                return dark
            default:
                return light
            }
        }
        self = .init(uiColor)
    }
}

extension UIColor {

    convenience init(_ value: UInt64, alpha: CGFloat = 1) {
        let red   = CGFloat(value >> 16 & 0xFF) / 255
        let green = CGFloat(value >> 08 & 0xFF) / 255
        let blue  = CGFloat(value >> 00 & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
