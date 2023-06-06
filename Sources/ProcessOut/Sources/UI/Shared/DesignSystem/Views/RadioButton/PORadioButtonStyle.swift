//
//  PORadioButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import Foundation

/// Describes radio button style in different states.
public final class PORadioButtonStyle {

    /// Style to use when radio button is in default state ie enabled and not selected.
    public let normal: PORadioButtonStateStyle

    /// Style to use when radio button is selected.
    public let selected: PORadioButtonStateStyle

    /// Style to use when radio button is in error state.
    public let error: PORadioButtonStateStyle

    /// Creates style instance.
    public init(normal: PORadioButtonStateStyle, selected: PORadioButtonStateStyle, error: PORadioButtonStateStyle) {
        self.normal = normal
        self.selected = selected
        self.error = error
    }
}

extension PORadioButtonStyle {

    static let `default` = PORadioButtonStyle(
        normal: .init(tintColor: Asset.Colors.Border.primary.color, value: defaultValueStyle),
        selected: .init(tintColor: Asset.Colors.Button.primary.color, value: defaultValueStyle),
        error: .init(tintColor: Asset.Colors.Border.error.color, value: defaultValueStyle)
    )

    // MARK: - Private Properties

    private static let defaultValueStyle = POTextStyle(
        color: Asset.Colors.Text.primary.color, typography: .bodyDefault1
    )
}
