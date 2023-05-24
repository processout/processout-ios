//
//  POInputStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

/// Input's state style.
public struct POInputStateStyle {

    /// Text style.
    public let text: POTextStyle

    /// Placeholder text style.
    public let placeholder: POTextStyle

    /// Button's background color.
    public let backgroundColor: UIColor

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Tint color that is used by text field.
    public let tintColor: UIColor

    public init(
        text: POTextStyle,
        placeholder: POTextStyle,
        backgroundColor: UIColor,
        border: POBorderStyle,
        shadow: POShadowStyle,
        tintColor: UIColor
    ) {
        self.text = text
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.border = border
        self.shadow = shadow
        self.tintColor = tintColor
    }
}
