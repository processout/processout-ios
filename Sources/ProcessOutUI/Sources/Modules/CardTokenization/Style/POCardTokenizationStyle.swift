//
//  POCardTokenizationStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for card tokenization module.
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
    public let backgroundColor: UIColor

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle,
        sectionTitle: POTextStyle,
        input: POInputStyle,
        radioButton: some ButtonStyle,
        errorDescription: POTextStyle,
        backgroundColor: UIColor,
        actionsContainer: POActionsContainerStyle,
        separatorColor: UIColor
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

extension POCardTokenizationStyle {

    public static var `default`: POCardTokenizationStyle {
        POCardTokenizationStyle(
            title: POTextStyle(color: UIColor(poResource: .Text.primary), typography: .Medium.title),
            sectionTitle: POTextStyle(
                color: UIColor(poResource: .Text.secondary), typography: .Fixed.labelHeading
            ),
            input: .medium,
            radioButton: .radio,
            errorDescription: POTextStyle(color: UIColor(poResource: .Text.error), typography: .Fixed.label),
            backgroundColor: UIColor(poResource: .Surface.level1),
            actionsContainer: .default,
            separatorColor: UIColor(poResource: .Border.subtle)
        )
    }
}
