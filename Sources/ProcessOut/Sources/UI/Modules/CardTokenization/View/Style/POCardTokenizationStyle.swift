//
//  POCardTokenizationStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import UIKit

/// Defines style for card tokenization module.
@_spi(PO)
public struct POCardTokenizationStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Radio button style.
    public let radioButton: PORadioButtonStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Actions style.
    public let actions: POActionsContainerStyle

    /// Background color.
    public let backgroundColor: UIColor

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle? = nil,
        sectionTitle: POTextStyle? = nil,
        input: POInputStyle? = nil,
        radioButton: PORadioButtonStyle? = nil,
        errorDescription: POTextStyle? = nil,
        actions: POActionsContainerStyle? = nil,
        backgroundColor: UIColor? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? Constants.title
        self.sectionTitle = sectionTitle ?? Constants.sectionTitle
        self.input = input ?? Constants.input
        self.radioButton = radioButton ?? Constants.radioButton
        self.errorDescription = errorDescription ?? Constants.errorDescription
        self.actions = actions ?? Constants.actions
        self.backgroundColor = backgroundColor ?? Constants.backgroundColor
        self.separatorColor = separatorColor ?? Constants.separatorColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let title = POTextStyle(color: UIColor(resource: .Text.primary), typography: .Medium.title)
        static let sectionTitle = POTextStyle(
            color: UIColor(resource: .Text.secondary), typography: .Fixed.labelHeading
        )
        static let input = POInputStyle.default()
        static let radioButton = PORadioButtonStyle.default
        static let errorDescription = POTextStyle(color: UIColor(resource: .Text.error), typography: .Fixed.label)
        static let actions = POActionsContainerStyle()
        static let backgroundColor = UIColor(resource: .Surface.level1)
        static let separatorColor = UIColor(resource: .Border.subtle)
    }
}