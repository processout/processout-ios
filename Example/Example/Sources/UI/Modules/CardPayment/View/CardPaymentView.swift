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
            Section(header: Text(.CardPayment.Invoice.title)) {
                TextField(
                    String(localized: .CardPayment.Invoice.name),
                    text: $viewModel.state.invoice.name
                )
                TextField(
                    String(localized: .CardPayment.Invoice.amount),
                    text: $viewModel.state.invoice.amount
                )
                Picker(data: $viewModel.state.invoice.currencyCode) { code in
                    Text(Locale.current.localizedString(forCurrencyCode: code.identifier) ?? code.identifier)
                } label: {
                    Text(.CardPayment.Invoice.currency)
                }
            }
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
            // swiftlint:disable:next line_length
            POCardTokenizationView(configuration: item.configuration, delegate: item.delegate, completion: item.completion)
                .presentationDetents([.fraction(0.75), .large])
        }
        .onSubmit {
            viewModel.pay()
        }
        .navigationTitle(String(localized: .CardPayment.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @Environment(\.dismiss)
    private var dismiss

    @State
    private var viewModel = CardPaymentViewModel()
}
