//
//  UIColor+Brightness.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

extension UIColor {

    func isLight(threshold: CGFloat = 0.5) -> Bool? {
        perceptualLightness.map { $0 > threshold }
    }

    // MARK: - Private Methods

    /// Returns the relative luminance of this color in range [0, 1].
    ///
    /// - NOTE: Alpha is ignored
    private var perceptualLightness: CGFloat? {
        guard let luminance else {
            return nil
        }
        if luminance <= 0.008856 { // Based on CIE standard
            return luminance * 9.033
        }
        return pow(luminance, 1 / 3) * 1.16 - 0.16
    }

    private var luminance: CGFloat? {
        // swiftlint:disable:next force_unwrapping
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB)!
        let convertedColor = cgColor.converted(to: colorSpace, intent: .defaultIntent, options: nil)
        guard let components = convertedColor?.components, components.count >= 3 else {
            return nil
        }
        // swiftlint:disable identifier_name
        let r = linearValue(ofGammaEncoded: components[0])
        let g = linearValue(ofGammaEncoded: components[1])
        let b = linearValue(ofGammaEncoded: components[2])
        // swiftlint:enable identifier_name
        return 0.2126 * r + 0.7152 * g + 0.0722 * b
    }

    /// Convert a gamma encoded RGB to a linear value.
    private func linearValue(ofGammaEncoded component: CGFloat) -> CGFloat {
        if component <= 0.04045 {
            return component / 12.92
        }
        return pow((component + 0.055) / 1.055, 2.4)
    }
}
