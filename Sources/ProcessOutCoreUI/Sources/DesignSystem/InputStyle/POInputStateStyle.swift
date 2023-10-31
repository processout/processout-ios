//
//  POInputStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import SwiftUI

/// Defines input's styling information in a specific state.
public struct POInputStateStyle {

    /// Text style.
    public let text: POTextStyle

    /// Placeholder text style.
    public let placeholder: POTextStyle

    /// Input's background color.
    public let backgroundColor: Color

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Tint color that is used by input.
    public let tintColor: Color

    /// Creates style instance.
    public init(
        text: POTextStyle,
        placeholder: POTextStyle,
        backgroundColor: Color,
        border: POBorderStyle,
        shadow: POShadowStyle,
        tintColor: Color
    ) {
        self.text = text
        self.placeholder = placeholder
        self.backgroundColor = backgroundColor
        self.border = border
        self.shadow = shadow
        self.tintColor = tintColor
    }
}
