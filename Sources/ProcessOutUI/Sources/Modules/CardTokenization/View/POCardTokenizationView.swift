//
//  POCardTokenizationView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 24.07.2023.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// View that allows user to enter card details and tokenize it.
@MainActor
public struct POCardTokenizationView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<CardTokenizationViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            switch presentationContext {
            case .standalone:
                ScrollView(showsIndicators: false) {
                    CardTokenizationContentView(viewModel: viewModel)
                }
                .clipped()
            case .inline:
                CardTokenizationContentView(viewModel: viewModel)
            }
            if let controls = viewModel.state.controls, !prefersInlineLayout(controlGroup: controls) {
                POActionsContainerView(actions: controls.buttons)
                    .actionsContainerStyle(style.actionsContainer)
            }
        }
        .backport.background {
            style.backgroundColor.ignoresSafeArea()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.cardTokenizationStyle)
    private var style

    @Environment(\.cardTokenizationPresentationContext)
    private var presentationContext

    @StateObject
    private var viewModel: AnyViewModel<CardTokenizationViewModelState>

    // MARK: - Private Methods

    private func prefersInlineLayout(controlGroup: CardTokenizationViewModelControlGroup) -> Bool {
        switch presentationContext {
        case .inline:
            return true
        case .standalone:
            return controlGroup.inline
        }
    }
}
