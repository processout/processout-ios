//
//  POInputFormStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

public struct POInputFormStateStyle {

    /// Title style.
    public let title: POTextStyle

    /// Input field style.
    public let field: POTextFieldStyle

    /// Description style.
    public let description: POTextStyle

    public init(title: POTextStyle, field: POTextFieldStyle, description: POTextStyle) {
        self.title = title
        self.field = field
        self.description = description
    }
}

extension POInputFormStateStyle {

    public static let normal = Self(
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
    )

    public static let error = Self(
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
}
