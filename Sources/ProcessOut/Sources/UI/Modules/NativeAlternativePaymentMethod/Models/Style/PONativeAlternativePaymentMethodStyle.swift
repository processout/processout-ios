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

    /// Background color.
    public let backgroundColor: UIColor

    /// Activity indicator style.
    public let activityIndicator: POActivityIndicatorStyle

    /// Message style.
    public let message: POTextStyle

    /// Success message style.
    public let successMessage: POTextStyle

    /// Background decoration style.
    public let backgroundDecoration: POBackgroundDecorationStyle

    /// Separator color.
    public let separatorColor: UIColor

    public init(
        title: POTextStyle? = nil,
        input: POInputFormStyle? = nil,
        codeInput: POInputFormStyle? = nil,
        buttons: PONativeAlternativePaymentMethodButtonsStyle? = nil,
        backgroundColor: UIColor? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        successMessage: POTextStyle? = nil,
        backgroundDecoration: POBackgroundDecorationStyle? = nil,
        separatorColor: UIColor? = nil
    ) {
        self.title = title ?? POTextStyle(color: Asset.Colors.New.Text.primary.color, typography: .Medium.title)
        self.input = input ?? .default
        self.codeInput = codeInput ?? .code
        self.buttons = buttons ?? .init()
        self.backgroundColor = backgroundColor ?? Asset.Colors.New.Surface.level1.color
        self.activityIndicator = activityIndicator ?? .system(.whiteLarge, color: Asset.Colors.New.Text.secondary.color)
        self.message = message ?? POTextStyle(color: Asset.Colors.New.Text.primary.color, typography: .Fixed.body)
        self.successMessage = successMessage ?? POTextStyle(
            color: Asset.Colors.New.Text.success.color, typography: .Fixed.body
        )
        self.backgroundDecoration = .default
        self.separatorColor = separatorColor ?? Asset.Colors.New.Border.subtle.color
    }
}
