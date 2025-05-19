//
//  PORadioButtonStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import SwiftUI

/// Describes radio button style in a particular state, for example when selected.
public struct PORadioButtonStateStyle: Sendable {

    /// Styling of the radio button knob not including value.
    public let knob: PORadioButtonKnobStateStyle

    /// Radio button's value style.
    public let value: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    /// Creates state style.
    public init(knob: PORadioButtonKnobStateStyle, value: POTextStyle, backgroundColor: Color = .clear) {
        self.knob = knob
        self.value = value
        self.backgroundColor = backgroundColor
    }
}
