//
//  PORadioButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import UIKit

/// Describes radio button style in different states.
public struct PORadioButtonStyle {

    /// Style to use when radio button is in default state ie enabled and not selected.
    public let normal: PORadioButtonStateStyle

    /// Style to use when radio button is selected.
    public let selected: PORadioButtonStateStyle

    /// Style to use when radio button is highlighted. Note that radio can transition
    /// to this state when already selected.
    public let highlighted: PORadioButtonStateStyle

    /// Style to use when radio button is in error state.
    public let error: PORadioButtonStateStyle

    /// Creates style instance.
    public init(
        normal: PORadioButtonStateStyle,
        selected: PORadioButtonStateStyle,
        highlighted: PORadioButtonStateStyle,
        error: PORadioButtonStateStyle
    ) {
        self.normal = normal
        self.selected = selected
        self.highlighted = highlighted
        self.error = error
    }
}

extension PORadioButtonStyle {

    static let `default` = PORadioButtonStyle(
        normal: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: UIColor(poResource: .Border.default)),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        ),
        selected: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: UIColor(poResource: .Action.Primary.default)),
                innerCircleColor: UIColor(poResource: .Action.Primary.default),
                innerCircleRadius: 4
            ),
            value: valueStyle
        ),
        highlighted: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: UIColor(poResource: .Text.muted)),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        ),
        error: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: UIColor(poResource: .Text.error)),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        )
    )

    // MARK: - Private Properties

    private static let valueStyle = POTextStyle(color: UIColor(poResource: .Text.primary), typography: .Fixed.label)
}
