//
//  DynamicCheckoutView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutUI

struct DynamicCheckoutView: View {

    var body: some View {
        Form {
            if let viewModel = viewModel.state.message {
                MessageView(viewModel: viewModel)
            }
            InvoiceView(viewModel: $viewModel.state.invoice)
            Button(String(localized: .DynamicCheckout.pay)) {
                viewModel.pay()
            }
        }
        .sheet(item: $viewModel.state.dynamicCheckout) { item in
            PODynamicCheckoutView(
                configuration: item.configuration, delegate: item.delegate, completion: item.completion
            )
        }
        .onSubmit {
            viewModel.pay()
        }
        .navigationTitle(String(localized: .DynamicCheckout.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var viewModel = DynamicCheckoutViewModel()
}

#Preview {
    DynamicCheckoutView()
}
