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

    init(viewModel: @autoclosure @escaping () -> some ViewModel<CardTokenizationViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                CardTokenizationContentView(viewModel: viewModel)
            }
            .clipped()
            POActionsContainerView(actions: viewModel.state.actions)
                .actionsContainerStyle(style.actionsContainer)
        }
        .backport.background {
            style.backgroundColor.ignoresSafeArea()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>
}
