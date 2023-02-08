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
    public let title: POTextStyle?

    /// Input style.
    public let input: POInputFormStyle?

    /// Input style.
    public let codeInput: POInputFormStyle?

    /// Style for primary button.
    public let primaryButton: POButtonStyle?

    /// Style that is applied to buttons container when it overlaps primary content.
    public let buttonsContainerShadow: POShadowStyle?

    /// Background color.
    public let backgroundColor: UIColor?

    /// Activity indicator style.
    public let activityIndicator: POActivityIndicatorStyle?

    /// Message style.
    public let message: POTextStyle?

    /// Success message style.
    public let successMessage: POTextStyle?

    /// Background decoration style.
    public let backgroundDecoration: POBackgroundDecorationStyle?

    public init(
        title: POTextStyle? = nil,
        input: POInputFormStyle? = nil,
        codeInput: POInputFormStyle? = nil,
        primaryButton: POButtonStyle? = nil,
        buttonsContainerShadow: POShadowStyle? = nil,
        backgroundColor: UIColor? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        successMessage: POTextStyle? = nil,
        backgroundDecoration: POBackgroundDecorationStyle? = nil
    ) {
        self.title = title
        self.input = input
        self.codeInput = codeInput
        self.primaryButton = primaryButton
        self.buttonsContainerShadow = buttonsContainerShadow
        self.backgroundColor = backgroundColor
        self.activityIndicator = activityIndicator
        self.message = message
        self.successMessage = successMessage
        self.backgroundDecoration = backgroundDecoration
    }
}
