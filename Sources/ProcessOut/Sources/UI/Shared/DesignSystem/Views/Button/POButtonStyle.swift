//
//  POButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

/// Defines button style in all possible states.
@available(*, deprecated, message: "Use ProcessOutUI module.")
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

@available(*, deprecated)
extension POButtonStyle {

    /// Default style for primary button.
    public static let primary = POButtonStyle(
        normal: .init(
            title: .init(color: UIColor(poResource: .Text.on), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(poResource: .Action.Primary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(poResource: .Text.on), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(poResource: .Action.Primary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(poResource: .Text.disabled), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(poResource: .Action.Primary.disabled)
        ),
        activityIndicator: activityIndicatorStyle(color: UIColor(poResource: .Text.on))
    )

    /// Default style for secondary button.
    public static let secondary = POButtonStyle(
        normal: .init(
            title: .init(color: UIColor(poResource: .Text.secondary), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(poResource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(poResource: .Action.Secondary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(poResource: .Text.secondary), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(poResource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(poResource: .Action.Secondary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(poResource: .Text.disabled), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(poResource: .Action.Border.disabled)),
            shadow: .clear,
            backgroundColor: .clear
        ),
        activityIndicator: activityIndicatorStyle(color: UIColor(poResource: .Text.secondary))
    )

    // MARK: - Private Methods

    private static func activityIndicatorStyle(color: UIColor) -> POActivityIndicatorStyle {
        .system(.medium, color: color)
    }
}
