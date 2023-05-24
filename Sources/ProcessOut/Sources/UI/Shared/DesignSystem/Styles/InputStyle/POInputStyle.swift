//
//  POInputStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.05.2023.
//

import UIKit

@available(*, deprecated, renamed: "POInputStyle")
public typealias POTextFieldStyle = POInputStyle

/// Input style.
public struct POInputStyle {

    /// Style for normal state.
    public let normal: POInputStateStyle

    /// Style for error state.
    public let error: POInputStateStyle

    /// Creates style instance.
    public init(normal: POInputStateStyle, error: POInputStateStyle) {
        self.normal = normal
        self.error = error
    }
}

extension POInputStyle {

    /// Default input form style.
    static func `default`(typography: POTypography = .Fixed.label) -> POInputStyle {
        POInputStyle(
            normal: POInputStateStyle(
                text: .init(color: Asset.Colors.Text.primary.color, typography: typography),
                placeholder: .init(color: Asset.Colors.Text.muted.color, typography: typography),
                backgroundColor: Asset.Colors.Surface.background.color,
                border: .regular(radius: 8, color: Asset.Colors.Border.default.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.primary.color
            ),
            error: POInputStateStyle(
                text: .init(color: Asset.Colors.Text.primary.color, typography: typography),
                placeholder: .init(color: Asset.Colors.Text.muted.color, typography: typography),
                backgroundColor: Asset.Colors.Surface.background.color,
                border: .regular(radius: 8, color: Asset.Colors.Text.error.color),
                shadow: .clear,
                tintColor: Asset.Colors.Text.error.color
            )
        )
    }
}
