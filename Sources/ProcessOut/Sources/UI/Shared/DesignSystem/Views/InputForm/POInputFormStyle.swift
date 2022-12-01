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
        normal: POInputFormStateStyle(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault1),
            field: .init(
                text: .init(color: Asset.Colors.Text.primary.color, typography: .title),
                placeholder: .init(color: Asset.Colors.Text.secondary.color, typography: .title),
                backgroundColor: Asset.Colors.Background.input.color,
                border: .init(radius: 8, width: 1, color: Asset.Colors.Border.primary.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.primary.color
            ),
            description: .init(color: Asset.Colors.Text.secondary.color, typography: .bodySmall2)
        ),
        error: POInputFormStateStyle(
            title: .init(color: Asset.Colors.Text.primary.color, typography: .bodyDefault1),
            field: .init(
                text: .init(color: Asset.Colors.Text.error.color, typography: .title),
                placeholder: .init(color: Asset.Colors.Text.error.color, typography: .title),
                backgroundColor: Asset.Colors.Background.input.color,
                border: .init(radius: 8, width: 1, color: Asset.Colors.Border.error.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.error.color
            ),
            description: .init(color: Asset.Colors.Text.error.color, typography: .bodySmall2)
        )
    )
}
