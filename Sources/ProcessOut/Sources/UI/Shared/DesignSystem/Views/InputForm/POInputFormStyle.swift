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
        normal: normal(fieldTypography: .Fixed.label), error: error(fieldTypography: .Fixed.label)
    )

    /// Default code input form style.
    public static let code = Self(
        normal: normal(fieldTypography: .Medium.title), error: error(fieldTypography: .Medium.title)
    )

    // MARK: - Private Methods

    private static func normal(fieldTypography: POTypography) -> POInputFormStateStyle {
        POInputFormStateStyle(
            title: .init(color: Asset.Colors.New.Text.secondary.color, typography: .Fixed.labelHeading),
            field: .init(
                text: .init(color: Asset.Colors.New.Text.primary.color, typography: fieldTypography),
                placeholder: .init(color: Asset.Colors.New.Text.muted.color, typography: fieldTypography),
                backgroundColor: Asset.Colors.New.Surface.background.color,
                border: .regular(radius: 8, color: Asset.Colors.New.Border.default.color),
                shadow: .clear,
                tintColor: Asset.Colors.New.Text.primary.color
            ),
            description: .init(color: Asset.Colors.New.Text.muted.color, typography: .Fixed.label)
        )
    }

    private static func error(fieldTypography: POTypography) -> POInputFormStateStyle {
        POInputFormStateStyle(
            title: .init(color: Asset.Colors.New.Text.secondary.color, typography: .Fixed.labelHeading),
            field: .init(
                text: .init(color: Asset.Colors.New.Text.primary.color, typography: fieldTypography),
                placeholder: .init(color: Asset.Colors.New.Text.muted.color, typography: fieldTypography),
                backgroundColor: Asset.Colors.New.Surface.background.color,
                border: .init(radius: 8, width: 1, color: Asset.Colors.New.Text.error.color),
                shadow: .clear,
                tintColor: Asset.Colors.New.Text.error.color
            ),
            description: .init(color: Asset.Colors.New.Text.error.color, typography: .Fixed.label)
        )
    }
}
