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
    @MainActor
    @preconcurrency
    public static var primary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(poResource: .Text.inverse), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Primary.Background.default)
            ),
            highlighted: .init(
                title: .init(color: Color(poResource: .Text.inverse), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Primary.Background.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(poResource: .Text.disabled), typography: .button),
                border: .clear,
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Primary.Background.disabled)
            ),
            progressStyle: CircularProgressViewStyle(tint: Color(poResource: .Text.inverse))
        )
    }

    /// Default style for secondary button.
    @_disfavoredOverload
    @MainActor
    @preconcurrency
    public static var secondary: POButtonStyle<CircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: Color(poResource: .Text.primary), typography: .button),
                border: .regular(color: Color(poResource: .Button.Secondary.Border.default)),
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Secondary.Background.default)
            ),
            highlighted: .init(
                title: .init(color: Color(poResource: .Text.primary), typography: .button),
                border: .regular(color: Color(poResource: .Button.Secondary.Border.selected)),
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Secondary.Background.pressed)
            ),
            disabled: .init(
                title: .init(color: Color(poResource: .Text.disabled), typography: .button),
                border: .regular(color: Color(poResource: .Button.Secondary.Border.disabled)),
                shadow: .clear,
                backgroundColor: Color(poResource: .Button.Secondary.Background.disabled)
            ),
            progressStyle: CircularProgressViewStyle(tint: Color(poResource: .Text.primary))
        )
    }
}
