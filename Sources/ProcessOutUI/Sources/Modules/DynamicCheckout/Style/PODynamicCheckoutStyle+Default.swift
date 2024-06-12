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
        inputTitle: POTextStyle(color: Color(poResource: .Text.secondary), typography: .label1),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        bodyText: POTextStyle(color: Color(poResource: .Text.primary), typography: .body2),
        errorText: POTextStyle(color: Color(poResource: .Text.error), typography: .label2),
        message: .toast,
        backgroundColor: Color(poResource: .Surface.level1),
        actionsContainer: .default,
        paymentSuccess: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.RegularPaymentMethod {

    /// Default dynamic checkout regular payment method style.
    public static let `default` = Self(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .title),
        informationText: POTextStyle(color: Color(poResource: .Text.primary), typography: .body2),
        border: POBorderStyle.regular(color: Color(poResource: .Text.muted)),
        disabledBackgroundColor: Color(poResource: .Surface.neutral)
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.PaymentSuccess {

    /// Default dynamic checkout capture success style.
    public static let `default` = Self(
        message: POTextStyle(color: Color(poResource: .Text.success), typography: .body2),
        backgroundColor: Color(poResource: .Surface.success)
    )
}
