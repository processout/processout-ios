//
//  PORadioButtonKnobStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.06.2023.
//

import SwiftUI

/// Describes radio button knob style in a particular state.
public struct PORadioButtonKnobStateStyle: Sendable {

    /// Background color.
    public let backgroundColor: Color

    /// Border style.
    /// - NOTE: component ignores specified border radius so your implementation may pass 0.
    public let border: POBorderStyle

    /// Color of inner circle displayed in the middle of radio button.
    public let innerCircleColor: Color

    /// Inner circle radius.
    public let innerCircleRadius: CGFloat

    /// Create style instance.
    public init(backgroundColor: Color, border: POBorderStyle, innerCircleColor: Color, innerCircleRadius: CGFloat) {
        self.backgroundColor = backgroundColor
        self.border = border
        self.innerCircleColor = innerCircleColor
        self.innerCircleRadius = innerCircleRadius
    }
}
