//
//  PODynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import PassKit
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for dynamic checkout view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@available(iOS 14, *)
@_spi(PO)
public struct PODynamicCheckoutStyle {

    public struct RegularPaymentMethod {

        /// Payment method title.
        public let title: POTextStyle

        /// Information text style.
        public let informationText: POTextStyle

        /// Border style to apply to regular payments.
        public let border: POBorderStyle

        /// Background color to use when payment method is unavailable.
        public let disabledBackgroundColor: Color

        public init(
            title: POTextStyle,
            informationText: POTextStyle,
            border: POBorderStyle,
            disabledBackgroundColor: Color
        ) {
            self.title = title
            self.informationText = informationText
            self.border = border
            self.disabledBackgroundColor = disabledBackgroundColor
        }
    }

    public struct PaymentSuccess {

        /// Success message style.
        public let message: POTextStyle

        /// Success background style.
        public let backgroundColor: Color

        /// Creates style instance.
        public init(message: POTextStyle, backgroundColor: Color) {
            self.message = message
            self.backgroundColor = backgroundColor
        }
    }

    /// PassKit payment button style.
    public let passKitPaymentButtonStyle: POPassKitPaymentButtonStyle

    /// Generic express payment button style. When default style is used, equals to
    /// `POBrandButtonStyle.brand` that automatically resolves styling based on branding.
    public let expressPaymentButtonStyle: any ButtonStyle

    /// Regular payment method style.
    public let regularPaymentMethod: RegularPaymentMethod

    /// Progress view style.
    public let progressView: any ProgressViewStyle

    /// Input title text style.
    public let inputTitle: POTextStyle

    /// Input style.
    public let input: POInputStyle

    /// Input style.
    public let codeInput: POInputStyle

    /// Radio button style.
    public let radioButton: any ButtonStyle

    /// Main content text style. For example in context of native alternative payment method
    /// this is used to style instruction user needs to follow in order to capture payment.
    public let bodyText: POTextStyle

    /// Error description text style.
    public let errorText: POTextStyle

    /// Informational message style.
    public let message: any POMessageViewStyle

    /// Background color.
    public let backgroundColor: Color

    /// Actions container style.
    public let actionsContainer: POActionsContainerStyle

    /// Success style.
    public let paymentSuccess: PaymentSuccess

    /// Creates dynamic checkout style.
    public init(
        passKitPaymentButtonStyle: POPassKitPaymentButtonStyle,
        expressPaymentButtonStyle: some ButtonStyle,
        regularPaymentMethod: RegularPaymentMethod,
        progressView: some ProgressViewStyle,
        inputTitle: POTextStyle,
        input: POInputStyle,
        codeInput: POInputStyle,
        radioButton: some ButtonStyle,
        bodyText: POTextStyle,
        errorText: POTextStyle,
        message: some POMessageViewStyle,
        backgroundColor: Color,
        actionsContainer: POActionsContainerStyle,
        paymentSuccess: PaymentSuccess
    ) {
        self.passKitPaymentButtonStyle = passKitPaymentButtonStyle
        self.expressPaymentButtonStyle = expressPaymentButtonStyle
        self.regularPaymentMethod = regularPaymentMethod
        self.progressView = progressView
        self.inputTitle = inputTitle
        self.input = input
        self.codeInput = codeInput
        self.radioButton = radioButton
        self.bodyText = bodyText
        self.errorText = errorText
        self.message = message
        self.backgroundColor = backgroundColor
        self.actionsContainer = actionsContainer
        self.paymentSuccess = paymentSuccess
    }
}
