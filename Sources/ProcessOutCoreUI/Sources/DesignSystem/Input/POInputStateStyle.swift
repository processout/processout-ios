//
//  POInputStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import UIKit

/// Defines input's styling information in a specific state.
public struct POInputStateStyle {

    /// Text style.
    public let text: POTextStyle

    /// Placeholder text style.
    public let placeholder: POTextStyle

    /// Input's background color.
    public let backgroundColor: UIColor

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Tint color that is used by input.
    public let tintColor: UIColor

    /// Creates style instance.
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
