//
//  DynamicCheckoutAlternativePaymentView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@MainActor
struct DynamicCheckoutAlternativePaymentView: View {

    init(item: DynamicCheckoutViewModelItem.AlternativePayment) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.large) {
            NativeAlternativePaymentContentView(viewModel: viewModel, insets: .init(horizontal: 0, vertical: 0))
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<NativeAlternativePaymentViewModelState>
}
