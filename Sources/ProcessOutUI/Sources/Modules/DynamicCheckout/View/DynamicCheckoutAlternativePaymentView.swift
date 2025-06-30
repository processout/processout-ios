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
        input = style.input
        largeInput = style.codeInput
        radioButton = style.radioButton
        toggle = style.toggle
        primaryButton = style.actionsContainer.primary
        secondaryButton = style.actionsContainer.secondary
        progressView = style.progressView
        bodyText = style.bodyText
        backgroundColor = style.backgroundColor
        separatorColor = PONativeAlternativePaymentStyle.default.separatorColor
    }
}
