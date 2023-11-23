//
//  PONativeAlternativePaymentMethodStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for native alternative payment method module.
@available(iOS 14, *)
public struct PONativeAlternativePaymentMethodStyle {

    /// Title style.
    public let title: POTextStyle

    /// Section title text style.
    public let sectionTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Error description text style.
    public let errorDescription: POTextStyle

    /// Actions style.
    public let actions: POActionsContainerStyle

    /// Activity indicator style. Please note that maximum height of activity indicator
    /// is limited to 256.
    public let activityIndicator: any ProgressViewStyle

    /// Message style.
    ///
    /// - NOTE: This style may be used to render rich attributed text so please make sure that your font's
    /// typeface supports different variations. Currently framework may use bold, italic and mono space traits.
    public let message: POTextStyle

    /// Success message style.
    public let successMessage: POTextStyle

    /// Background style.
    public let background: PONativeAlternativePaymentMethodBackgroundStyle

    /// Separator color.
    public let separatorColor: Color

    public init(
        title: POTextStyle,
        sectionTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: some ButtonStyle,
        errorDescription: POTextStyle,
        actions: POActionsContainerStyle,
        activityIndicator: some ProgressViewStyle,
        message: POTextStyle,
        successMessage: POTextStyle,
        background: PONativeAlternativePaymentMethodBackgroundStyle,
        separatorColor: Color
    ) {
        self.title = title
        self.sectionTitle = sectionTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.errorDescription = errorDescription
        self.actions = actions
        self.activityIndicator = activityIndicator
        self.message = message
        self.successMessage = successMessage
        self.background = background
        self.separatorColor = separatorColor
    }
}

@available(iOS 14, *)
extension PONativeAlternativePaymentMethodStyle {

    /// Default native alternative payment method style.
    public static let `default` = PONativeAlternativePaymentMethodStyle(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
        sectionTitle: POTextStyle(
            color: Color(poResource: .Text.secondary), typography: .Fixed.labelHeading
        ),
        input: .medium,
        codeInput: .large,
        radioButton: .radio,
        errorDescription: POTextStyle(color: Color(poResource: .Text.error), typography: .Fixed.label),
        actions: .default,
        activityIndicator: .circular,
        message: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body),
        successMessage: POTextStyle(color: Color(poResource: .Text.success), typography: .Fixed.body),
        background: .default,
        separatorColor: Color(poResource: .Border.subtle)
    )
}
