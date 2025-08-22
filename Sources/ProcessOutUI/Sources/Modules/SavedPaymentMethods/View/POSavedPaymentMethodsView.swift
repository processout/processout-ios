//
//  POSavedPaymentMethodsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

/// Saved payment methods root view.
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
            contentUnavailable: {
                if viewModel.state.isContentUnavailable {
                    POContentUnavailableView {
                        Label {
                            Text(
                                String(
                                    resource: .SavedPaymentMethods.ContentUnavailable.title,
                                    configuration: viewModel.state.localizationConfiguration
                                )
                            )
                        } icon: {
                            Image(poResource: .creditCard).resizable()
                        }
                    } description: {
                        Text(
                            String(
                                resource: .SavedPaymentMethods.ContentUnavailable.description,
                                configuration: viewModel.state.localizationConfiguration
                            )
                        )
                    }
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
