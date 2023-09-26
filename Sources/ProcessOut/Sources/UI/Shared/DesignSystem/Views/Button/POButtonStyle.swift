//
//  POButtonStyle.swift
//  ProcessOut
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
            title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
            border: .clear(radius: 8),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.disabled)
        ),
        activityIndicator: activityIndicatorStyle(color: UIColor(resource: .Text.on))
    )

    /// Default style for secondary button.
    public static let secondary = POButtonStyle(
        normal: .init(
            title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(resource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Secondary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(resource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Secondary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
            border: .regular(radius: 8, color: UIColor(resource: .Action.Border.disabled)),
            shadow: .clear,
            backgroundColor: .clear
        ),
        activityIndicator: activityIndicatorStyle(color: UIColor(resource: .Text.secondary))
    )

    // MARK: - Private Methods

    private static func activityIndicatorStyle(color: UIColor) -> POActivityIndicatorStyle {
        if #available(iOS 13.0, *) {
            return .system(.medium, color: color)
        }
        return .system(.white, color: color)
    }
}
