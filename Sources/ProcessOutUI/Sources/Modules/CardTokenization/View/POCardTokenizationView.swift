//
//  POCardTokenizationView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to enter card details and tokenize it.
@available(iOS 14, *)
public struct POCardTokenizationView: View {

    init(viewModel: some CardTokenizationViewModel) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { scrollView in
                ScrollView(showsIndicators: false) {
                    CardTokenizationContentView(scrollView: scrollView, viewModel: viewModel)
                }
                .clipped()
            }
            if !viewModel.state.actions.isEmpty {
                POActionsContainerView(actions: viewModel.state.actions)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .background(style.backgroundColor.ignoresSafeArea())
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @StateObject
    private var viewModel: AnyCardTokenizationViewModel
}
