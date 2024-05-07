//
//  DynamicCheckoutAlternativePaymentItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct DynamicCheckoutAlternativePaymentItemView: View {

    init(item: DynamicCheckoutViewModelItem.AlternativePayment) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        NativeAlternativePaymentContentView(viewModel: viewModel, horizontalPadding: POSpacing.medium)
            .nativeAlternativePaymentStyle(.init(dynamicCheckoutStyle: style))
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyNativeAlternativePaymentViewModel
}
