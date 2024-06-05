//
//  DynamicCheckoutCardItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14.0, *)
struct DynamicCheckoutCardItemView: View {

    init(item: DynamicCheckoutViewModelItem.Card) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        CardTokenizationContentView(viewModel: viewModel, horizontalPadding: POSpacing.medium)
            .cardTokenizationStyle(.init(dynamicCheckoutStyle: style))
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>
}
