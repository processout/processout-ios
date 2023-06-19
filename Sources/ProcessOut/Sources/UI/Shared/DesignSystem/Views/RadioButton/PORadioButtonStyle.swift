//
//  PORadioButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import Foundation

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
                border: .regular(radius: 0, color: Asset.Colors.Border.default.color),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        ),
        selected: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: Asset.Colors.Action.Primary.default.color),
                innerCircleColor: Asset.Colors.Action.Primary.default.color,
                innerCircleRadius: 4
            ),
            value: valueStyle
        ),
        highlighted: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: Asset.Colors.Text.muted.color),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        ),
        error: .init(
            knob: .init(
                backgroundColor: .clear,
                border: .regular(radius: 0, color: Asset.Colors.Text.error.color),
                innerCircleColor: .clear,
                innerCircleRadius: 0
            ),
            value: valueStyle
        )
    )

    // MARK: - Private Properties

    private static let valueStyle = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .Fixed.label)
}
