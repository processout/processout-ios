//
//  POInputStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.11.2022.
//

import SwiftUI

/// Defines input's styling information in a specific state.
public struct POInputStateStyle: Sendable {

    /// Text style.
    public let text: POTextStyle

    /// Label text style.
    public let label: POTextStyle

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
        label: POTextStyle,
        backgroundColor: Color,
        border: POBorderStyle,
        shadow: POShadowStyle,
        tintColor: Color
    ) {
        self.text = text
        self.label = label
        self.backgroundColor = backgroundColor
        self.border = border
        self.shadow = shadow
        self.tintColor = tintColor
    }
}

extension POInputStateStyle {

    /// Placeholder text style.
    @available(*, deprecated, renamed: "label")
    public var placeholder: POTextStyle {
        label
    }

    /// Creates style instance.
    @available(*, deprecated, message: "Use init that accepts label instead.")
    public init(
        text: POTextStyle,
        placeholder: POTextStyle,
        backgroundColor: Color,
        border: POBorderStyle,
        shadow: POShadowStyle,
        tintColor: Color
    ) {
        self.text = text
        self.label = placeholder
        self.backgroundColor = backgroundColor
        self.border = border
        self.shadow = shadow
        self.tintColor = tintColor
    }
}
