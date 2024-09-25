//
//  PORadioButtonKnobStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.06.2023.
//

import UIKit

/// Describes radio button knob style in a particular state.
@available(*, deprecated, message: "Use ProcessOutUI module.")
public struct PORadioButtonKnobStateStyle {

    /// Background color.
    public let backgroundColor: UIColor

    /// Border style.
    /// - NOTE: component  ignores specified border radius so your implementation may pass 0.
    public let border: POBorderStyle

    /// Color of inner circle displayed in the middle of radio button.
    public let innerCircleColor: UIColor

    /// Inner circle radius.
    public let innerCircleRadius: CGFloat

    /// Create style instance.
    public init(
        backgroundColor: UIColor,
        border: POBorderStyle,
        innerCircleColor: UIColor,
        innerCircleRadius: CGFloat
    ) {
        self.backgroundColor = backgroundColor
        self.border = border
        self.innerCircleColor = innerCircleColor
        self.innerCircleRadius = innerCircleRadius
    }
}
