//
//  PORadioButtonStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import UIKit

/// Describes radio button style in a particular state, for example when selected.
public struct PORadioButtonStateStyle {

    /// Tint color used primarly
    public let tintColor: UIColor

    /// Radio button's value style.
    public let value: POTextStyle

    /// Creates state style.
    public init(tintColor: UIColor, value: POTextStyle) {
        self.tintColor = tintColor
        self.value = value
    }
}
