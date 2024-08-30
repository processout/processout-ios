//
//  InvoiceView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 30.08.2024.
//

import SwiftUI

struct InvoiceView: View {

    init(viewModel: Binding<InvoiceViewModel>) {
        self._viewModel = viewModel
    }

    // MARK: - View

    var body: some View {
        Section {
            TextField(
                String(localized: .Invoice.name), text: $viewModel.name
            )
            TextField(
                String(localized: .Invoice.amount), text: $viewModel.amount
            )
            Picker(data: $viewModel.currencyCode) { code in
                Text(Locale.current.localizedString(forCurrencyCode: code.identifier) ?? code.identifier)
            } label: {
                Text(.Invoice.currency)
            }
        } header: {
            Text(.Invoice.title)
        }
    }

    // MARK: - Private Properties

    @Binding
    private var viewModel: InvoiceViewModel
}
