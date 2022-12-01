//
//  PONativeAlternativePaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import UIKit

/// Defines style for native alternative payment method module.
public struct PONativeAlternativePaymentMethodStyle {

    public struct BackgroundDecorationStyle {

        /// Primary color.
        public let primaryColor: UIColor

        /// Secondary color.
        public let secondaryColor: UIColor
    }

    /// Title style.
    public let title: POTextStyle?

    /// Input style.
    public let input: POInputFormStyle?

    /// Style for primary button.
    public let primaryButton: POButtonStyle?

    /// Background color.
    public let backgroundColor: UIColor?

    /// Activity indicator style.
    public let activityIndicator: POActivityIndicatorStyle?

    /// Message style.
    public let message: POTextStyle?

    /// Background decoration style.
    public let backgroundDecoration: BackgroundDecorationStyle?

    /// Success message style.
    public let successMessage: POTextStyle?

    /// Success background decoration style.
    public let successBackgroundDecoration: BackgroundDecorationStyle?

    public init(
        title: POTextStyle? = nil,
        input: POInputFormStyle? = nil,
        primaryButton: POButtonStyle? = nil,
        backgroundColor: UIColor? = nil,
        activityIndicator: POActivityIndicatorStyle? = nil,
        message: POTextStyle? = nil,
        backgroundDecoration: BackgroundDecorationStyle? = nil,
        successMessage: POTextStyle? = nil,
        successBackgroundDecoration: BackgroundDecorationStyle? = nil
    ) {
        self.title = title
        self.input = input
        self.primaryButton = primaryButton
        self.backgroundColor = backgroundColor
        self.activityIndicator = activityIndicator
        self.message = message
        self.backgroundDecoration = backgroundDecoration
        self.successMessage = successMessage
        self.successBackgroundDecoration = successBackgroundDecoration
    }
}
