//
//  POInputFormStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

public struct POInputFormStyle {

    /// Style for normal state.
    public let normal: POInputFormStateStyle

    /// Style for error style.
    public let error: POInputFormStateStyle

    public init(normal: POInputFormStateStyle, error: POInputFormStateStyle) {
        self.normal = normal
        self.error = error
    }
}

extension POInputFormStyle {

    /// Default input form style.
    public static let `default` = Self(
        normal: normal(fieldTypography: .bodyDefault1), error: error(fieldTypography: .bodyDefault1)
    )

    /// Default code input form style.
    public static let code = Self(
        normal: normal(fieldTypography: .title), error: error(fieldTypography: .title)
    )

    // MARK: - Private Methods

    private static func normal(fieldTypography: POTypography) -> POInputFormStateStyle {
        POInputFormStateStyle(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyLarge),
            field: .init(
                text: .init(color: Asset.Colors.Text.primary.color, typography: fieldTypography),
                placeholder: .init(color: Asset.Colors.Text.secondary.color, typography: fieldTypography),
                backgroundColor: Asset.Colors.Background.input.color,
                border: .init(radius: 8, width: 1, color: Asset.Colors.Border.primary.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.primary.color
            ),
            description: .init(color: Asset.Colors.Text.secondary.color, typography: .bodySmall2)
        )
    }

    private static func error(fieldTypography: POTypography) -> POInputFormStateStyle {
        POInputFormStateStyle(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyLarge),
            field: .init(
                text: .init(color: Asset.Colors.Text.primary.color, typography: fieldTypography),
                placeholder: .init(color: Asset.Colors.Text.secondary.color, typography: fieldTypography),
                backgroundColor: Asset.Colors.Background.input.color,
                border: .init(radius: 8, width: 1, color: Asset.Colors.Border.error.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.error.color
            ),
            description: .init(color: Asset.Colors.Text.error.color, typography: .bodySmall2)
        )
    }
}
