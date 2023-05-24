//
//  PONativeAlternativePaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

/// Defines style for native alternative payment method module.
public struct PONativeAlternativePaymentMethodStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Buttons style.
    public let buttons: PONativeAlternativePaymentMethodButtonsStyle

    /// Activity indicator style.
    public let activityIndicator: POActivityIndicatorStyle

    /// Message style.
    public let message: POTextStyle

    /// Success message style.
    public let successMessage: POTextStyle

    /// Background style.
    public let background: PONativeAlternativePaymentMethodBackgroundStyle

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle? = nil,
        sectionTitle: POTextStyle? = nil,
        input: POInputStyle? = nil,
        codeInput: POInputStyle? = nil,
        errorDescription: POTextStyle? = nil,
        buttons: PONativeAlternativePaymentMethodButtonsStyle? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        successMessage: POTextStyle? = nil,
        background: PONativeAlternativePaymentMethodBackgroundStyle? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? Constants.title
        self.sectionTitle = sectionTitle ?? Constants.sectionTitle
        self.input = input ?? Constants.input
        self.codeInput = codeInput ?? Constants.codeInput
        self.errorDescription = errorDescription ?? Constants.errorDescription
        self.buttons = buttons ?? Constants.buttons
        self.activityIndicator = activityIndicator ?? Constants.activityIndicator
        self.message = message ?? Constants.message
        self.successMessage = successMessage ?? Constants.successMessage
        self.background = background ?? Constants.background
        self.separatorColor = separatorColor ?? Constants.separatorColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let title = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .Medium.title)
        static let sectionTitle = POTextStyle(color: Asset.Colors.Text.secondary.color, typography: .Fixed.labelHeading)
        static let input = POInputStyle.default()
        static let codeInput = POInputStyle.default(typography: .Medium.title)
        static let errorDescription = POTextStyle(color: Asset.Colors.Text.error.color, typography: .Fixed.label)
        static let buttons = PONativeAlternativePaymentMethodButtonsStyle()
        static let activityIndicator = POActivityIndicatorStyle.system(
            .whiteLarge, color: Asset.Colors.Text.secondary.color
        )
        static let message = POTextStyle(color: Asset.Colors.Text.primary.color, typography: .Medium.subtitle)
        static let successMessage = POTextStyle(color: Asset.Colors.Text.success.color, typography: .Medium.subtitle)
        static let background = PONativeAlternativePaymentMethodBackgroundStyle()
        static let separatorColor = Asset.Colors.Border.subtle.color
    }
}
