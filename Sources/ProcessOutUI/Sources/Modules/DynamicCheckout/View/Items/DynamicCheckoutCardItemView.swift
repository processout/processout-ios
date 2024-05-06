//
//  DynamicCheckoutCardItemView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 06.05.2024.
//

import SwiftUI

@available(iOS 14.0, *)
struct DynamicCheckoutCardItemView: View {

    init(item: DynamicCheckoutViewModelItem.Card) {
        _viewModel = .init(wrappedValue: item.viewModel())
    }

    // MARK: - View

    var body: some View {
        CardTokenizationContentView(viewModel: viewModel)
            .cardTokenizationStyle(.init(dynamicCheckoutStyle: style))
            .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.dynamicCheckoutStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardTokenizationViewModel
}
