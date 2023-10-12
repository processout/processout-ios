//
//  POButtonStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

/// Defines button's styling information in a specific state.
public struct POButtonStateStyle {

    /// Title typography.
    public let title: POTextStyle

    /// Border style.
    public let border: POBorderStyle

    /// Shadow style.
    public let shadow: POShadowStyle

    /// Background color.
    public let backgroundColor: UIColor

    public init(title: POTextStyle, border: POBorderStyle, shadow: POShadowStyle, backgroundColor: UIColor) {
        self.title = title
        self.border = border
        self.shadow = shadow
        self.backgroundColor = backgroundColor
    }
}
