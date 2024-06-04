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
        section: .default,
        subsection: .default,
        progressView: .circular,
        inputTitle: POTextStyle(color: Color(poResource: .Text.secondary), typography: .Fixed.labelHeading),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        errorText: POTextStyle(color: Color(poResource: .Text.error), typography: .Fixed.label),
        passKitPaymentButtonStyle: POPassKitPaymentButtonStyle(),
        expressPaymentButtonStyle: .brand,
        message: .toast,
        backgroundColor: Color(poResource: .Surface.level1),
        success: .default,
        actionsContainer: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.Section {

    /// Default dynamic checkout section style.
    public static let `default` = PODynamicCheckoutStyle.Section(
        border: POBorderStyle.regular(color: Color(poResource: .Text.muted))
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.Subsection {

    /// Default dynamic checkout subsection style.
    public static let `default` = PODynamicCheckoutStyle.Subsection(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body),
        informationText: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.label),
        dividerColor: Color(poResource: .Text.muted)
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.Success {

    /// Default dynamic checkout subsection style.
    public static let `default` = PODynamicCheckoutStyle.Success(
        message: POTextStyle(color: Color(poResource: .Text.success), typography: .Fixed.body),
        backgroundColor: Color(poResource: .Surface.success)
    )
}
