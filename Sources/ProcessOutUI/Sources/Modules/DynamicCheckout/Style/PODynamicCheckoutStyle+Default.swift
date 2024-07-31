//
//  PODynamicCheckoutStyle+Default.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension PODynamicCheckoutStyle {

    /// Default dynamic checkout style.
    public static let `default` = PODynamicCheckoutStyle(
        passKitPaymentButtonStyle: POPassKitPaymentButtonStyle(),
        expressPaymentButtonStyle: .brand,
        regularPaymentMethod: .default,
        progressView: .circular,
        inputTitle: POTextStyle(color: Color(poResource: .Text.primary), typography: .label1),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        bodyText: POTextStyle(color: Color(poResource: .Text.primary), typography: .body1),
        errorText: POTextStyle(color: Color(poResource: .Text.error), typography: .label2),
        message: .toast,
        backgroundColor: Color(poResource: .Surface.default),
        actionsContainer: .default,
        paymentSuccess: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.RegularPaymentMethod {

    /// Default dynamic checkout regular payment method style.
    public static let `default` = Self(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .subheading),
        informationText: POTextStyle(color: Color(poResource: .Text.muted), typography: .body2),
        border: POBorderStyle.regular(color: Color(poResource: .Border.subtle))
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.PaymentSuccess {

    /// Default dynamic checkout capture success style.
    public static let `default` = Self(
        message: POTextStyle(color: Color(poResource: .Text.success), typography: .body1),
        backgroundColor: Color(poResource: .Surface.success)
    )
}
