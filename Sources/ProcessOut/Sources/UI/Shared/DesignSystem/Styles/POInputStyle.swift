//
//  POInputStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

public struct POInputStyle {

    public struct Style {

        /// Title style.
        public let title: POTextStyle

        /// Subtitle style.
        public let subtitle: POTextStyle

        /// Input field style.
        public let field: POTextFieldStyle

        /// Description style.
        public let description: POTextStyle

        public init(title: POTextStyle, subtitle: POTextStyle, field: POTextFieldStyle, description: POTextStyle) {
            self.title = title
            self.subtitle = subtitle
            self.field = field
            self.description = description
        }
    }

    /// Normal style.
    public let normal: Style

    /// Error style.
    public let error: Style

    public init(normal: Style, error: Style) {
        self.normal = normal
        self.error = error
    }
}

extension POInputStyle.Style {

    public static let normal = POInputStyle.Style(
        title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault1),
        subtitle: .init(color: Asset.Colors.Text.secondary.color, typography: .bodySmall2),
        field: .init(
            text: .init(color: Asset.Colors.Text.primary.color, typography: .title),
            backgroundColor: Asset.Colors.Background.input.color,
            cornerRadius: 8,
            borderColor: Asset.Colors.Border.primary.color,
            borderWidth: 1,
            carretColor: Asset.Colors.Text.primary.color
        ),
        description: .init(color: Asset.Colors.Text.secondary.color, typography: .bodySmall2)
    )

    public static let error = POInputStyle.Style(
        title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault1),
        subtitle: .init(color: Asset.Colors.Text.secondary.color, typography: .bodySmall2),
        field: .init(
            text: .init(color: Asset.Colors.Text.error.color, typography: .title),
            backgroundColor: Asset.Colors.Background.input.color,
            cornerRadius: 8,
            borderColor: Asset.Colors.Border.error.color,
            borderWidth: 1,
            carretColor: Asset.Colors.Text.error.color
        ),
        description: .init(color: Asset.Colors.Text.error.color, typography: .bodySmall2)
    )
}

extension POInputStyle {

    /// Default text style.
    static let `default` = POInputStyle(normal: .normal, error: .error)
}
