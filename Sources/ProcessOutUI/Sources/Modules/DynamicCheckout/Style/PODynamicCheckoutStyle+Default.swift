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
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
        section: .default,
        subsection: .default,
        progressView: .circular,
        inputTitle: POTextStyle(color: Color(poResource: .Text.secondary), typography: .Fixed.labelHeading),
        input: .medium,
        codeInput: .large,
        radioButton: PORadioButtonStyle.radio,
        errorText: POTextStyle(color: Color(poResource: .Text.error), typography: .Fixed.label),
        passKitPaymentButtonStyle: .automatic,
        expressPaymentButtonStyle: .brand,
        backgroundColor: Color(poResource: .Surface.level1),
        actionsContainer: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.Section {

    /// Default dynamic checkout section style.
    public static let `default` = PODynamicCheckoutStyle.Section(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
        border: POBorderStyle.regular(color: Color(poResource: .Text.muted)),
        divider: .default
    )
}

@available(iOS 14, *)
extension PODynamicCheckoutStyle.Subsection {

    /// Default dynamic checkout subsection style.
    public static let `default` = PODynamicCheckoutStyle.Subsection(
        title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
        informationText: POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body),
        dividerColor: Color(poResource: .Text.muted)
    )
}
