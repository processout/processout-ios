//
//  POInputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.05.2023.
//

import UIKit

/// Defines input control style in both normal and error states.
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

    /// Allows to create default input style with given typography.
    public static func `default`(typography: POTypography? = nil) -> POInputStyle {
        POInputStyle(
            normal: POInputStateStyle(
                text: .init(color: UIColor(resource: .Text.primary), typography: typography ?? .Fixed.label),
                placeholder: .init(color: UIColor(resource: .Text.muted), typography: typography ?? .Fixed.label),
                backgroundColor: UIColor(resource: .Surface.background),
                border: .regular(color: UIColor(resource: .Border.default)),
                shadow: .clear,
                tintColor: UIColor(resource: .Text.primary)
            ),
            error: POInputStateStyle(
                text: .init(color: UIColor(resource: .Text.primary), typography: typography ?? .Fixed.label),
                placeholder: .init(color: UIColor(resource: .Text.muted), typography: typography ?? .Fixed.label),
                backgroundColor: UIColor(resource: .Surface.background),
                border: .regular(color: UIColor(resource: .Text.error)),
                shadow: .clear,
                tintColor: UIColor(resource: .Text.error)
            )
        )
    }
}
