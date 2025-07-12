//
//  DynamicCheckoutCardView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
@MainActor
struct DynamicCheckoutCardView: View {

    init(item: DynamicCheckoutViewModelItem.Card) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: POSpacing.large) {
            CardTokenizationContentView(viewModel: viewModel, insets: 0)
            DynamicCheckoutPaymentMethodButtonsView(buttons: viewModel.state.actions)
        }
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>
}
