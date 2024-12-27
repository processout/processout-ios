//
//  POSavedPaymentMethodsView.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI

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
        Text("Hello, World!")
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel: AnyViewModel<SavedPaymentMethodsViewModelState>
}
