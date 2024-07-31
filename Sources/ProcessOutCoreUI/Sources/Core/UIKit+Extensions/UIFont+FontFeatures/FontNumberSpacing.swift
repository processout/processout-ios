//
//  FontNumberSpacing.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import CoreText

@_spi(PO)
public struct POFontNumberSpacing: Sendable {

    let rawValue: Int
}

extension POFontNumberSpacing {

    /// Uniform width numbers, useful for displaying in columns.
    public static let monospaced = Self(rawValue: kMonospacedNumbersSelector)

    /// Numbers whose widths vary.
    public static let proportional = Self(rawValue: kProportionalNumbersSelector)

    /// Thin numerals.
    public static let thirdWidth = Self(rawValue: kThirdWidthNumbersSelector)

    /// Very thin numerals.
    public static let quarterWidth = Self(rawValue: kQuarterWidthNumbersSelector)
}

extension POFontNumberSpacing: FontFeatureSetting {

    var featureType: Int {
        kNumberSpacingType
    }

    var featureSelector: Any {
        rawValue
    }
}
