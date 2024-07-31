//
//  POInputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.05.2023.
//

import SwiftUI

/// Defines input control style in both normal and error states.
public struct POInputStyle {

    /// Style for normal state.
    public let normal: POInputStateStyle

    /// Style for error state.
    public let error: POInputStateStyle

    /// Style for focused state.
    public let focused: POInputStateStyle

    /// Creates style instance.
    public init(normal: POInputStateStyle, error: POInputStateStyle, focused: POInputStateStyle? = nil) {
        self.normal = normal
        self.error = error
        self.focused = focused ?? normal
    }
}

extension POInputStyle {

    /// Medium size input style.
    public static let medium = `default`(typography: .body2)

    /// Large input style.
    public static let large = `default`(typography: .title)

    // MARK: - Utils

    /// Resolves state style with given context.
    func resolve(isInvalid: Bool, isFocused: Bool) -> POInputStateStyle {
        if isInvalid {
            return error
        } else if isFocused {
            return focused
        }
        return normal
    }

    // MARK: - Private Methods

    private static func `default`(typography: POTypography) -> POInputStyle {
        let stateStyle = { (borderColorResource: POColorResource) in
            POInputStateStyle(
                text: .init(color: Color(poResource: .Text.primary), typography: typography),
                placeholder: .init(color: Color(poResource: .Text.muted), typography: typography),
                backgroundColor: Color(poResource: .Surface.default),
                border: .regular(color: Color(poResource: borderColorResource)),
                shadow: .clear,
                tintColor: Color(poResource: .Text.primary)
            )
        }
        let style = POInputStyle(
            normal: stateStyle(.Input.Border.default),
            error: stateStyle(.Input.Border.error),
            focused: stateStyle(.Input.Border.focused)
        )
        return style
    }
}
