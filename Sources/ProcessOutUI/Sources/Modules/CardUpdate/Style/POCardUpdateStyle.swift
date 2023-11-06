//
//  POCardUpdateStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for card update view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@available(iOS 14, *)
public struct POCardUpdateStyle {

    /// Title style.
    public let title: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Separator color.
    public let separatorColor: Color

    public init(
        title: POTextStyle,
        input: POInputStyle,
        errorDescription: POTextStyle,
        backgroundColor: Color,
        actionsContainer: POActionsContainerStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.input = input
        self.errorDescription = errorDescription
        self.backgroundColor = backgroundColor
        self.actionsContainer = actionsContainer
        self.separatorColor = separatorColor
    }
}

@available(iOS 14, *)
extension POCardUpdateStyle {

    /// Default card tokenization style.
    public static var `default`: POCardUpdateStyle {
        POCardUpdateStyle(
            title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
            input: .medium,
            errorDescription: POTextStyle(color: Color(poResource: .Text.error), typography: .Fixed.label),
            backgroundColor: Color(poResource: .Surface.level1),
            actionsContainer: .default,
            separatorColor: Color(poResource: .Border.subtle)
        )
    }
}
