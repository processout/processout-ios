//
//  POCardTokenizationStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for card tokenization view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@available(iOS 14, *)
public struct POCardTokenizationStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

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
        sectionTitle: POTextStyle,
        input: POInputStyle,
        radioButton: some ButtonStyle,
        errorDescription: POTextStyle,
        backgroundColor: Color,
        actionsContainer: POActionsContainerStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.sectionTitle = sectionTitle
        self.input = input
        self.radioButton = radioButton
        self.errorDescription = errorDescription
        self.backgroundColor = backgroundColor
        self.actionsContainer = actionsContainer
        self.separatorColor = separatorColor
    }
}

@available(iOS 14, *)
extension POCardTokenizationStyle {

    /// Default card tokenization style.
    public static var `default`: POCardTokenizationStyle {
        POCardTokenizationStyle(
            title: POTextStyle(color: Color(.Text.primary), typography: .title),
            sectionTitle: POTextStyle(color: Color(.Text.primary), typography: .label1),
            input: .medium,
            radioButton: .radio,
            errorDescription: POTextStyle(color: Color(.Text.error), typography: .label2),
            backgroundColor: Color(.Surface.default),
            actionsContainer: .default,
            separatorColor: Color(.Border.subtle)
        )
    }
}
