//
//  POInputStyle+Default.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.01.2025.
//

import SwiftUI

extension POInputStyle {

    /// Medium size input style.
    public static let medium = POInputStyle(
        normal: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s15(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Label.default,
                typography: .Text.s15(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.default),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        error: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s15(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Label.error,
                typography: .Text.s15(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.error),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        focused: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s15(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Label.default,
                typography: .Text.s15(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.focused, focused: true),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        errorFocused: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s15(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Label.error,
                typography: .Text.s15(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.error, focused: true),
            shadow: .clear,
            tintColor: Color.Input.tint
        )
    )

    /// Large input style.
    public static let large = POInputStyle(
        normal: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s20(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Text.default,
                typography: .Text.s16(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.default),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        error: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s20(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Text.error,
                typography: .Text.s16(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.error),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        focused: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s20(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Text.default,
                typography: .Text.s16(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.focused, focused: true),
            shadow: .clear,
            tintColor: Color.Input.tint
        ),
        errorFocused: .init(
            text: .init(
                color: Color.Input.Text.default,
                typography: .Text.s20(weight: .medium)
            ),
            label: .init(
                color: Color.Input.Text.error,
                typography: .Text.s16(weight: .medium)
            ),
            backgroundColor: Color.Input.Background.default,
            border: .input(color: Color.Input.Border.error, focused: true),
            shadow: .clear,
            tintColor: Color.Input.tint
        )
    )

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
}
