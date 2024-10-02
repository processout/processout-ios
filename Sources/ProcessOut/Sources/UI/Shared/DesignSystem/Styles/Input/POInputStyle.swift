//
//  POInputStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.05.2023.
//

import UIKit

@available(*, deprecated, renamed: "POInputStyle")
public typealias POTextFieldStyle = POInputStyle

/// Defines input control style in both normal and error states.
@available(*, deprecated, message: "Use ProcessOutUI module.")
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

@available(*, deprecated)
extension POInputStyle {

    /// Allows to create default input style with given typography.
    public static func `default`(typography: POTypography? = nil) -> POInputStyle {
        POInputStyle(
            normal: POInputStateStyle(
                text: .init(color: UIColor(poResource: .Text.primary), typography: typography ?? .Fixed.label),
                placeholder: .init(color: UIColor(poResource: .Text.muted), typography: typography ?? .Fixed.label),
                backgroundColor: UIColor(poResource: .Surface.background),
                border: .regular(radius: 8, color: UIColor(poResource: .Border.default)),
                shadow: .clear,
                tintColor: UIColor(poResource: .Text.primary)
            ),
            error: POInputStateStyle(
                text: .init(color: UIColor(poResource: .Text.primary), typography: typography ?? .Fixed.label),
                placeholder: .init(color: UIColor(poResource: .Text.muted), typography: typography ?? .Fixed.label),
                backgroundColor: UIColor(poResource: .Surface.background),
                border: .regular(radius: 8, color: UIColor(poResource: .Text.error)),
                shadow: .clear,
                tintColor: UIColor(poResource: .Text.error)
            )
        )
    }
}
