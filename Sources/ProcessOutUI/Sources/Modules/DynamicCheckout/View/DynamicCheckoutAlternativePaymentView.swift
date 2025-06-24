//
//  DynamicCheckoutAlternativePaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutAlternativePaymentView: View {

    init(item: DynamicCheckoutViewModelItem.AlternativePayment) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.large) {
            NativeAlternativePaymentContentView(viewModel: viewModel, insets: .init(horizontal: 0, vertical: 0))
                .nativeAlternativePaymentSizeClass(.compact)
                .nativeAlternativePaymentStyle(.init(dynamicCheckoutStyle: style))
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>
}

@available(iOS 14, *)
extension PONativeAlternativePaymentStyle {

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(dynamicCheckoutStyle style: PODynamicCheckoutStyle) {
        title = PONativeAlternativePaymentStyle.default.title
        sectionTitle = style.inputTitle
        input = style.input
        codeInput = style.codeInput
        radioButton = style.radioButton
        toggle = style.toggle
        errorDescription = style.errorText
        actionsContainer = style.actionsContainer
        progressView = style.progressView
        message = style.bodyText
        successMessage = style.paymentSuccess.message
        backgroundColor = style.backgroundColor
        background = .init(regular: style.backgroundColor, success: style.paymentSuccess.backgroundColor)
        separatorColor = PONativeAlternativePaymentStyle.default.separatorColor
    }
}
