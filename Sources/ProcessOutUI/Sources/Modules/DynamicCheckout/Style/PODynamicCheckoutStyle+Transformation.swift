//
//  PODynamicCheckoutStyle+Transformation.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 26.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension POCardTokenizationStyle {

    init(dynamicCheckoutStyle style: PODynamicCheckoutStyle) {
        title = POCardTokenizationStyle.default.title
        sectionTitle = style.inputTitle
        input = style.input
        radioButton = style.radioButton
        errorDescription = style.errorText
        backgroundColor = style.backgroundColor
        actionsContainer = style.actionsContainer
        separatorColor = POCardTokenizationStyle.default.separatorColor
    }
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    init(dynamicCheckoutStyle style: PODynamicCheckoutStyle) {
        title = PONativeAlternativePaymentStyle.default.title
        sectionTitle = style.subsection.title
        input = style.input
        codeInput = style.codeInput
        radioButton = style.radioButton
        errorDescription = style.errorText
        actionsContainer = style.actionsContainer
        progressView = style.progressView
        // todo(andrii-vysotskyi): resolve message style from input style
        message = POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body)
        successMessage = style.success.message
        background = .init(regular: style.backgroundColor, success: style.success.backgroundColor)
        separatorColor = style.subsection.dividerColor
    }
}
