//
//  DynamicCheckoutAlternativePaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct DynamicCheckoutAlternativePaymentView: View {

    init(item: DynamicCheckoutViewModelItem.AlternativePayment) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        NativeAlternativePaymentContentView(
            viewModel: viewModel, insets: EdgeInsets(), shouldCenterParameters: false
        )
        .nativeAlternativePaymentStyle(.init(dynamicCheckoutStyle: style))
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyNativeAlternativePaymentViewModel
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(dynamicCheckoutStyle style: PODynamicCheckoutStyle) {
        title = PONativeAlternativePaymentStyle.default.title
        sectionTitle = style.regularPaymentMethod.title
        input = style.input
        codeInput = style.codeInput
        radioButton = style.radioButton
        errorDescription = style.errorText
        actionsContainer = style.actionsContainer
        progressView = style.progressView
        // todo(andrii-vysotskyi): resolve message style from input style
        message = POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body)
        successMessage = style.captureSuccess.message
        background = .init(regular: style.backgroundColor, success: style.captureSuccess.backgroundColor)
        separatorColor = PONativeAlternativePaymentStyle.default.separatorColor
    }
}
