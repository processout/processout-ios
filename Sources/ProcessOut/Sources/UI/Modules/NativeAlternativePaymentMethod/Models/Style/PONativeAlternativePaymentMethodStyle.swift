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

    /// Input style.
    public let input: POInputFormStyle

    /// Input style.
    public let codeInput: POInputFormStyle

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
        input: POInputFormStyle? = nil,
        codeInput: POInputFormStyle? = nil,
        buttons: PONativeAlternativePaymentMethodButtonsStyle? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        successMessage: POTextStyle? = nil,
        background: PONativeAlternativePaymentMethodBackgroundStyle? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? Constants.title
        self.input = input ?? Constants.input
        self.codeInput = codeInput ?? Constants.codeInput
        self.buttons = buttons ?? Constants.buttons
        self.activityIndicator = activityIndicator ?? Constants.activityIndicator
        self.message = message ?? Constants.message
        self.successMessage = successMessage ?? Constants.successMessage
        self.background = background ?? Constants.background
        self.separatorColor = separatorColor ?? Constants.separatorColor
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let title = POTextStyle(color: Asset.Colors.New.Text.primary.color, typography: .Medium.title)
        static let input = POInputFormStyle.default
        static let codeInput = POInputFormStyle.code
        static let buttons = PONativeAlternativePaymentMethodButtonsStyle()
        static let activityIndicator = POActivityIndicatorStyle.system(
            .whiteLarge, color: Asset.Colors.New.Text.secondary.color
        )
        static let message = POTextStyle(color: Asset.Colors.New.Text.primary.color, typography: .Fixed.body)
        static let successMessage = POTextStyle(color: Asset.Colors.New.Text.success.color, typography: .Fixed.body)
        static let background = PONativeAlternativePaymentMethodBackgroundStyle()
        static let separatorColor = Asset.Colors.New.Border.subtle.color
    }
}
