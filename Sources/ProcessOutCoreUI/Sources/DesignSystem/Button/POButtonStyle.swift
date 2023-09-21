//
//  POButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

/// Defines button style in all possible states.
public struct POButtonStyle {

    /// Style for normal state.
    public let normal: POButtonStateStyle

    /// Style for highlighted state.
    public let highlighted: POButtonStateStyle

    /// Style for disabled state.
    public let disabled: POButtonStateStyle

    /// Activity indicator style. Only used with normal state.
    public let activityIndicator: POActivityIndicatorStyle

    public init(
        normal: POButtonStateStyle,
        highlighted: POButtonStateStyle,
        disabled: POButtonStateStyle,
        activityIndicator: POActivityIndicatorStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.activityIndicator = activityIndicator
    }
}

extension POButtonStyle {

    /// Default style for primary button.
    public static let primary = POButtonStyle(
        normal: .init(
            title: .init(color: Asset.Colors.Text.onColor.color, typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Action.Primary.default.color
        ),
        highlighted: .init(
            title: .init(color: Asset.Colors.Text.onColor.color, typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Action.Primary.pressed.color
        ),
        disabled: .init(
            title: .init(color: Asset.Colors.Text.disabled.color, typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: Asset.Colors.Action.Primary.disabled.color
        ),
        activityIndicator: .system(.medium, color: Asset.Colors.Text.onColor.color)
    )

    /// Default style for secondary button.
    public static let secondary = POButtonStyle(
        normal: .init(
            title: .init(color: Asset.Colors.Text.secondary.color, typography: .Fixed.button),
            border: .regular(radius: 8, color: Asset.Colors.Border.default.color),
            shadow: .clear,
            backgroundColor: Asset.Colors.Action.Secondary.default.color
        ),
        highlighted: .init(
            title: .init(color: Asset.Colors.Text.secondary.color, typography: .Fixed.button),
            border: .regular(radius: 8, color: Asset.Colors.Border.default.color),
            shadow: .clear,
            backgroundColor: Asset.Colors.Action.Secondary.pressed.color
        ),
        disabled: .init(
            title: .init(color: Asset.Colors.Text.disabled.color, typography: .Fixed.button),
            border: .regular(radius: 8, color: Asset.Colors.Action.Border.disabled.color),
            shadow: .clear,
            backgroundColor: .clear
        ),
        activityIndicator: .system(.medium, color: Asset.Colors.Text.secondary.color)
    )
}
