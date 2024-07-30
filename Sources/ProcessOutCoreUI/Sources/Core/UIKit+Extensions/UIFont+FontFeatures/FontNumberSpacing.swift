//
//  FontNumberSpacing.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 30.07.2024.
//

import CoreText

struct FontNumberSpacing: RawRepresentable {

    let rawValue: Int

    /// Uniform width numbers, useful for displaying in columns.
    static let monospaced = Self(rawValue: kMonospacedNumbersSelector)

    /// Numbers whose widths vary.
    static let proportional = Self(rawValue: kProportionalNumbersSelector)

    /// Thin numerals.
    static let thirdWidth = Self(rawValue: kThirdWidthNumbersSelector)

    /// Very thin numerals.
    static let quarterWidth = Self(rawValue: kQuarterWidthNumbersSelector)
}

extension FontNumberSpacing: FontFeatureSetting {

    var featureType: Int {
        kNumberSpacingType
    }

    var featureSelector: Any {
        rawValue
    }
}
