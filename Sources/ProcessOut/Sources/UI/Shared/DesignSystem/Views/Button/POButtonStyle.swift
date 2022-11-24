//
//  POButtonStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

public struct POButtonStyle {

    public struct Style {

        /// Title style.
        public let titleColor: UIColor

        /// Button's background color.
        public let backgroundColor: UIColor

        /// Border color.
        public let borderColor: UIColor?

        public init(titleColor: UIColor, backgroundColor: UIColor, borderColor: UIColor?) {
            self.titleColor = titleColor
            self.backgroundColor = backgroundColor
            self.borderColor = borderColor
        }
    }

    /// Configuration to use when button is in default state.
    public let normal: Style

    /// Configuration to use when button is highlighted.
    public let highlighted: Style

    /// Configuration to use when button is disabled
    public let disabled: Style

    /// Text typography.
    public let typography: POTypography

    /// Corner radius.
    public let cornerRadius: CGFloat

    /// Border width.
    public let borderWidth: CGFloat

    /// Activity indicator style. Indicator is only used with normal state.
    public let activityIndicator: POActivityIndicatorStyle

    public init(
        normal: Style,
        highlighted: Style,
        disabled: Style,
        typography: POTypography,
        cornerRadius: CGFloat,
        borderWidth: CGFloat,
        activityIndicator: POActivityIndicatorStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.typography = typography
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.activityIndicator = activityIndicator
    }
}

extension POButtonStyle {

    public static let primary = POButtonStyle(
        normal: .init(
            titleColor: Asset.Colors.Text.primary.color,
            backgroundColor: Asset.Colors.Button.primary.color,
            borderColor: nil
        ),
        highlighted: .init(
            titleColor: Asset.Colors.Text.primary.color,
            backgroundColor: Asset.Colors.Button.highlighted.color,
            borderColor: nil
        ),
        disabled: .init(
            titleColor: Asset.Colors.Text.disabled.color,
            backgroundColor: Asset.Colors.Button.disabled.color,
            borderColor: nil
        ),
        typography: .bodyDefault2,
        cornerRadius: 8,
        borderWidth: 0,
        activityIndicator: .circle(Asset.Colors.Text.primary.color)
    )
}
