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
        inputTitle: POTextStyle(color: Color(poResource: .Text.secondary), typography: .Fixed.labelHeading),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        errorText: POTextStyle(color: Color(poResource: .Text.error), typography: .Fixed.label),
        message: .toast,
        backgroundColor: Color(poResource: .Surface.level1),
        actionsContainer: .default,
        captureSuccess: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.RegularPaymentMethod {

    /// Default dynamic checkout subsection style.
    public static let `default` = PODynamicCheckoutStyle.RegularPaymentMethod(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body),
        informationText: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.label),
        border: POBorderStyle.regular(color: Color(poResource: .Text.muted))
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.CaptureSuccess {

    /// Default dynamic checkout subsection style.
    public static let `default` = PODynamicCheckoutStyle.CaptureSuccess(
        message: POTextStyle(color: Color(poResource: .Text.success), typography: .Fixed.body),
        backgroundColor: Color(poResource: .Surface.success)
    )
}
