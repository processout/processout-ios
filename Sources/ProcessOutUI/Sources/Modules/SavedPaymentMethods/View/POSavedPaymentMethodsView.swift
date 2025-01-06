//
//  POSavedPaymentMethodsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Saved payment methods root view.
@available(iOS 14, *)
@_spi(PO)
@MainActor
public struct POSavedPaymentMethodsView: View {

    init(viewModel: @autoclosure @escaping () -> some ViewModel<SavedPaymentMethodsViewModelState>) {
        self._viewModel = .init(wrappedValue: .init(erasing: viewModel()))
    }

    // MARK: - View

    public var body: some View {
        let configuration = POSavedPaymentMethodsStyleConfiguration(
            title: {
                if let title = viewModel.state.title {
                    Text(title)
                }
            },
            paymentMethods: {
                ForEach(viewModel.state.paymentMethods) { paymentMethod in
                    SavedPaymentMethodView(viewModel: paymentMethod)
                }
            },
            message: {
                if let viewModel = viewModel.state.message {
                    POMessageView(message: viewModel)
                }
            },
            cancelButton: {
                if let viewModel = viewModel.state.cancelButton {
                    Button.create(with: viewModel)
                }
            },
            isLoading: viewModel.state.isLoading
        )
        AnyView(style.makeBody(configuration: configuration))
            .backport.geometryGroup()
            .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.savedPaymentMethodsStyle)
    private var style

    @StateObject
    private var viewModel: AnyViewModel<SavedPaymentMethodsViewModelState>
}

// todo(andrii-vysotskyi): complete before PR

// * Support empty state ?
// * Decide if name should be visible in default style
// * Add slide to delete
// * Add directly to example
// * Support transition from dynamic checkout
// * Support customization through the dynamic checkout
// * Remove deleted payment method in dynamic checkout
// * Add documentation
//   * In-project
//   * Process Out
// * Add tests
