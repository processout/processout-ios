//
//  UIColor+Brightness.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

extension UIColor {

    var brightness: CGFloat? {
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)! // swiftlint:disable:this force_unwrapping
        let convertedColor = cgColor.converted(
            to: colorSpace, intent: .defaultIntent, options: nil
        )
        guard let components = convertedColor?.components, components.count >= 3 else {
            return nil
        }
        // Calculation is based on this https://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        return (components[0] * 299 + components[1] * 587 + components[2] * 114) / 1000
    }

    func isLight(threshold: CGFloat = 0.5) -> Bool? {
        brightness.map { $0 > threshold }
    }
}
