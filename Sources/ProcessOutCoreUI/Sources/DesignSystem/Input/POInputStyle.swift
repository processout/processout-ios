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

    /// Medium size input style.
    @_spi(PO) public static let medium = `default`(typography: .Fixed.label)

    /// Large input style.
    @_spi(PO) public static let large = `default`(typography: .Medium.title)

    // MARK: - Private Methods

    private static func `default`(typography: POTypography) -> POInputStyle {
        POInputStyle(
            normal: POInputStateStyle(
                text: .init(color: UIColor(resource: .Text.primary), typography: typography),
                placeholder: .init(color: UIColor(resource: .Text.muted), typography: typography),
                backgroundColor: UIColor(resource: .Surface.background),
                border: .regular(color: UIColor(resource: .Border.default)),
                shadow: .clear,
                tintColor: UIColor(resource: .Text.primary)
            ),
            error: POInputStateStyle(
                text: .init(color: UIColor(resource: .Text.primary), typography: typography),
                placeholder: .init(color: UIColor(resource: .Text.muted), typography: typography),
                backgroundColor: UIColor(resource: .Surface.background),
                border: .regular(color: UIColor(resource: .Text.error)),
                shadow: .clear,
                tintColor: UIColor(resource: .Text.error)
            )
        )
    }
}
