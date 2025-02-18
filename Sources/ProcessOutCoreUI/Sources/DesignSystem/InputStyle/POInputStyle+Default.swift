//
//  POInputStyle+Default.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.01.2025.
//

import SwiftUI

extension POInputStyle {

    /// Medium size input style.
    public static let medium = `default`(typography: .Text.s14(weight: .regular))

    /// Large input style.
    public static let large = `default`(typography: .Text.s20(weight: .medium))

    // MARK: - Utils

    /// Resolves state style with given context.
    func resolve(isInvalid: Bool, isFocused: Bool) -> POInputStateStyle {
        if isInvalid {
            if isFocused {
                return errorFocused
            }
            return error
        } else if isFocused {
            return focused
        }
        return normal
    }

    // MARK: - Private Methods

    // swiftlint:disable:next function_body_length
    private static func `default`(typography: POTypography) -> POInputStyle {
        POInputStyle(
            normal: .init(
                text: .init(
                    color: Color.Input.Text.default,
                    typography: typography
                ),
                placeholder: .init(
                    color: Color.Input.Placeholder.default,
                    typography: typography
                ),
                backgroundColor: Color.Input.Background.default,
                border: .input(color: Color.Input.Border.default),
                shadow: .clear,
                tintColor: Color.Input.tint
            ),
            error: .init(
                text: .init(
                    color: Color.Input.Text.error,
                    typography: typography
                ),
                placeholder: .init(
                    color: Color.Input.Placeholder.error,
                    typography: typography
                ),
                backgroundColor: Color.Input.Background.error,
                border: .input(color: Color.Input.Border.error),
                shadow: .clear,
                tintColor: Color.Input.tint
            ),
            focused: .init(
                text: .init(
                    color: Color.Input.Text.focused,
                    typography: typography
                ),
                placeholder: .init(
                    color: Color.Input.Placeholder.focused,
                    typography: typography
                ),
                backgroundColor: Color.Input.Background.focused,
                border: .input(color: Color.Input.Border.focused),
                shadow: .clear,
                tintColor: Color.Input.tint
            ),
            errorFocused: .init(
                text: .init(
                    color: Color.Input.Text.errorFocused,
                    typography: typography
                ),
                placeholder: .init(
                    color: Color.Input.Placeholder.errorFocused,
                    typography: typography
                ),
                backgroundColor: Color.Input.Background.errorFocused,
                border: .input(color: Color.Input.Border.errorFocused),
                shadow: .clear,
                tintColor: Color.Input.tint
            )
        )
    }
}
