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
        let configuration = POSavedPaymentMethodsStyleConfiguration {
            Text("Manage saved payment methods")
        } paymentMethods: {
            ForEach(viewModel.state.paymentMethods) { paymentMethod in
                SavedPaymentMethodView(viewModel: paymentMethod)
            }
        } cancelButton: {
            Button("Cancel") { }
        }
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
