//
//  SavedPaymentMethodsView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 06.01.2025.
//

import SwiftUI
@_spi(PO) import ProcessOutUI

struct SavedPaymentMethodsView: View {

    var body: some View {
        Form {
            if let viewModel = viewModel.state.message {
                MessageView(viewModel: viewModel)
            }
            InvoiceView(viewModel: $viewModel.state.invoice)
            Button(String(localized: .SavedPaymentMethods.manage)) {
                viewModel.manage()
            }
        }
        .sheet(item: $viewModel.state.savedPaymentMethods) { viewModel in
            POSavedPaymentMethodsView(configuration: viewModel.configuration, completion: viewModel.completion)
        }
        .onSubmit {
            viewModel.manage()
        }
        .navigationTitle(String(localized: .SavedPaymentMethods.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel = SavedPaymentMethodsViewModel()
}

#Preview {
    SavedPaymentMethodsView()
}
