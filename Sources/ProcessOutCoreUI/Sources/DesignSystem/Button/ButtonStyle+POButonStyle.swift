//
//  ButtonStyle+POButonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension ButtonStyle where Self == POButtonStyle<CircularProgressViewStyle> {

    /// Default style for primary button.
    @_spi(PO) public static var primary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(.Text.on), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.default)
            ),
            highlighted: .init(
                title: .init(color: Color(.Text.on), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(.Text.disabled), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(.Action.Primary.disabled)
            ),
            progressView: CircularProgressViewStyle(tint: Color(.Text.on))
        )
    }

    /// Default style for secondary button.
    @_spi(PO) public static var secondary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(.Text.secondary), typography: .Fixed.button),
                border: .regular(color: Color(.Border.default)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.default)
            ),
            highlighted: .init(
                title: .init(color: Color(.Text.secondary), typography: .Fixed.button),
                border: .regular(color: Color(.Border.default)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(.Text.disabled), typography: .Fixed.button),
                border: .regular(color: Color(.Action.Border.disabled)),
                shadow: .clear,
                backgroundColor: Color(.Action.Secondary.default).opacity(0)
            ),
            progressView: CircularProgressViewStyle(tint: Color(.Text.secondary))
        )
    }
}
