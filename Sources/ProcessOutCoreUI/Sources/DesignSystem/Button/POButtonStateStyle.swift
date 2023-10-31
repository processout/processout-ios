//
//  POButtonStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import SwiftUI

/// Defines button's styling information in a specific state.
public struct POButtonStateStyle {

    /// Title typography.
    public let title: POTextStyle

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Background color.
    public let backgroundColor: Color

    public init(title: POTextStyle, border: POBorderStyle, shadow: POShadowStyle, backgroundColor: Color) {
        self.title = title
        self.border = border
        self.shadow = shadow
        self.backgroundColor = backgroundColor
    }
}
