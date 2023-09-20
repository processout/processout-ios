//
//  PORadioButtonStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import UIKit

/// Describes radio button style in a particular state, for example when selected.
public struct PORadioButtonStateStyle {

    /// Styling of the radio button knob not including value.
    public let knob: PORadioButtonKnobStateStyle

    /// Radio button's value style.
    public let value: POTextStyle

    /// Creates state style.
    public init(knob: PORadioButtonKnobStateStyle, value: POTextStyle) {
        self.knob = knob
        self.value = value
    }
}
