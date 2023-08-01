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

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Actions style.
    public let actions: PONativeAlternativePaymentMethodActionsStyle

    /// Background color.
    public let backgroundColor: UIColor

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle? = nil,
        sectionTitle: POTextStyle? = nil,
        input: POInputStyle? = nil,
        errorDescription: POTextStyle? = nil,
        actions: PONativeAlternativePaymentMethodActionsStyle? = nil,
        backgroundColor: UIColor? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? Constants.title
        self.sectionTitle = sectionTitle ?? Constants.sectionTitle
        self.input = input ?? Constants.input
        self.errorDescription = errorDescription ?? Constants.errorDescription
        self.actions = actions ?? Constants.actions
        self.backgroundColor = backgroundColor ?? Constants.backgroundColor
        self.separatorColor = separatorColor ?? Constants.separatorColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let title = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .Medium.title)
        static let sectionTitle = POTextStyle(color: Asset.Colors.Text.secondary.color, typography: .Fixed.labelHeading)
        static let input = POInputStyle.default()
        static let errorDescription = POTextStyle(color: Asset.Colors.Text.error.color, typography: .Fixed.label)
        static let actions = PONativeAlternativePaymentMethodActionsStyle()
        static let backgroundColor = Asset.Colors.Surface.level1.color
        static let separatorColor = Asset.Colors.Border.subtle.color
    }
}
