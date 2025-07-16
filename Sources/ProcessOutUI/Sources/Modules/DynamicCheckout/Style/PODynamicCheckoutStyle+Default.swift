//
//  PODynamicCheckoutStyle+Default.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

extension PODynamicCheckoutStyle {

    /// Default dynamic checkout style.
    public static let `default` = PODynamicCheckoutStyle(
        sectionHeader: .default,
        passKitPaymentButtonStyle: POPassKitPaymentButtonStyle(),
        expressPaymentButtonStyle: .brand,
        regularPaymentMethod: .default,
        progressView: .circular,
        inputTitle: POTextStyle(color: .Input.Text.default, typography: .Text.s14(weight: .medium)),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        toggle: .poCheckbox,
        bodyText: POTextStyle(color: .Text.primary, typography: .Paragraph.s16(weight: .medium)),
        errorText: POTextStyle(color: .Input.Text.error, typography: .Text.s12(weight: .regular)),
        message: .toast,
        backgroundColor: .Surface.primary,
        actionsContainer: .default,
        paymentSuccess: .default
    )
}

extension PODynamicCheckoutStyle.SectionHeader {

    /// Default dynamic checkout regular payment method style.
    public static let `default` = Self(
        title: POTextStyle(color: .Text.primary, typography: .Text.s16(weight: .medium)),
        trailingButton: .ghost
    )
}

extension PODynamicCheckoutStyle.RegularPaymentMethod {

    /// Default dynamic checkout regular payment method style.
    public static let `default` = Self(
        title: POTextStyle(color: .Text.primary, typography: .Text.s14(weight: .medium)),
        informationText: POTextStyle(color: .Text.secondary, typography: .Text.s14(weight: .regular)),
        border: .regular(color: .Border.primary),
        backgroundColor: .Surface.primary
    )
}

extension PODynamicCheckoutStyle.PaymentSuccess {

    /// Default dynamic checkout capture success style.
    public static let `default` = Self(
        message: POTextStyle(color: .Text.positive, typography: .Paragraph.s16(weight: .medium)),
        backgroundColor: .Surface.successSubtle
    )
}
