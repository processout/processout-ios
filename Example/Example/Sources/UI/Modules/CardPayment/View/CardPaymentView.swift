//
//  CardPaymentView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import SwiftUI
import ProcessOutUI

struct CardPaymentView: View {

    var body: some View {
        Form {
            if let viewModel = viewModel.state.message {
                MessageView(viewModel: viewModel)
            }
            InvoiceView(viewModel: $viewModel.state.invoice)
            Section {
                Picker(data: $viewModel.state.authenticationService) { service in
                    Text(service.rawValue.capitalized)
                } label: {
                    Text(.CardPayment.threeDSService)
                }
            }
            Button(String(localized: .CardPayment.pay)) {
                viewModel.pay()
            }
        }
        .sheet(item: $viewModel.state.cardTokenization) { item in
            POCardTokenizationView(
                configuration: item.configuration, delegate: item.delegate, completion: item.completion
            )
        }
        .onSubmit {
            viewModel.pay()
        }
        .navigationTitle(String(localized: .CardPayment.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @State
    private var viewModel = CardPaymentViewModel()
}

#Preview {
    CardPaymentView()
}
