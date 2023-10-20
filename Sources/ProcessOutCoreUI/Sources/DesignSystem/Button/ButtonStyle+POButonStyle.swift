//
//  ButtonStyle+POButonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension ButtonStyle where Self == POButtonStyle<POCircularProgressViewStyle> {

    /// Default style for primary button.
    @_spi(PO) public static var primary: POButtonStyle<POCircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: UIColor(resource: .Action.Primary.default)
            ),
            highlighted: .init(
                title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: UIColor(resource: .Action.Primary.pressed)
            ),
            disabled: .init(
                title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
                border: .clear,
                shadow: .clear,
                backgroundColor: UIColor(resource: .Action.Primary.disabled)
            ),
            progressView: .circular(tint: UIColor(resource: .Text.on))
        )
    }

    /// Default style for secondary button.
    @_spi(PO) public static var secondary: POButtonStyle<POCircularProgressViewStyle> {
        POButtonStyle(
            normal: .init(
                title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
                border: .regular(color: UIColor(resource: .Border.default)),
                shadow: .clear,
                backgroundColor: UIColor(resource: .Action.Secondary.default)
            ),
            highlighted: .init(
                title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
                border: .regular(color: UIColor(resource: .Border.default)),
                shadow: .clear,
                backgroundColor: UIColor(resource: .Action.Secondary.pressed)
            ),
            disabled: .init(
                title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
                border: .regular(color: UIColor(resource: .Action.Border.disabled)),
                shadow: .clear,
                backgroundColor: .clear
            ),
            progressView: .circular(tint: UIColor(resource: .Text.secondary))
        )
    }
}
