//
//  UITraitCollection+ColorAppearance.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.12.2022.
//

import UIKit

extension UITraitCollection {

    // Return whether this trait collection, compared to a different trait collection, could show a different
    // appearance for dynamic colors that are provided by UIKit or are in an asset catalog.
    func isColorAppearanceDifferent(to traitCollection: UITraitCollection?) -> Bool {
        let isDifferent = displayGamut != traitCollection?.displayGamut
            || userInterfaceIdiom != traitCollection?.userInterfaceIdiom
            || userInterfaceStyle != traitCollection?.userInterfaceStyle
            || accessibilityContrast != traitCollection?.accessibilityContrast
            || userInterfaceLevel != traitCollection?.userInterfaceLevel
        return isDifferent
    }
}
