//
//  ButtonStyle+POButonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

@available(iOS 14, *)
extension ButtonStyle where Self == POButtonStyle<CircularProgressViewStyle> {

    /// Default style for primary button.
    @_disfavoredOverload
    public static var primary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(.Text.inverse), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.default)
            ),
            highlighted: .init(
                title: .init(color: Color(.Text.inverse), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(.Text.disabled), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.disabled)
            ),
            progressStyle: CircularProgressViewStyle(tint: Color(.Text.inverse))
        )
    }

    /// Default style for secondary button.
    @_disfavoredOverload
    public static var secondary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(.Text.primary), typography: .button),
                border: .regular(color: Color(.Border.default)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.default)
            ),
            highlighted: .init(
                title: .init(color: Color(.Text.primary), typography: .button),
                border: .regular(color: Color(.Border.default)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(.Text.disabled), typography: .button),
                border: .regular(color: Color(.Action.Border.disabled)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.default).opacity(0)
            ),
            progressStyle: CircularProgressViewStyle(tint: Color(.Text.primary))
        )
    }
}
