//
//  DynamicCheckoutView.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

/// Dynamic checkout root view.
@available(iOS 14, *)
@_spi(PO)
@MainActor
public struct PODynamicCheckoutView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<DynamicCheckoutViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                ScrollView(showsIndicators: true) {
                    DynamicCheckoutContentView(sections: viewModel.state.sections)
                        .frame(minHeight: geometry.size.height, alignment: .top)
                }
                .modify { content in
                    if #available(iOS 16.0, *) {
                        content.scrollDismissesKeyboard(.interactively)
                    } else {
                        content
                    }
                }
                .clipped()
            }
            POActionsContainerView(actions: viewModel.state.actions)
                .actionsContainerStyle(style.actionsContainer)
        }
        .backport.background {
            let backgroundColor = viewModel.state.isCompleted
                ? style.paymentSuccess.backgroundColor : style.backgroundColor
            backgroundColor
                .ignoresSafeArea()
                .animation(.default, value: viewModel.state.isCompleted)
        }
        .backport.geometryGroup()
        .onAppear(perform: viewModel.start)
        .sheet(item: $viewModel.state.savedPaymentMethods) { viewModel in
            POSavedPaymentMethodsView(configuration: viewModel.configuration, completion: viewModel.completion)
                .fittedPresentationDetent()
        }
        .poConfirmationDialog(item: $viewModel.state.confirmationDialog)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyViewModel<DynamicCheckoutViewModelState>

    @Environment(\.dynamicCheckoutStyle)
    private var style
}
