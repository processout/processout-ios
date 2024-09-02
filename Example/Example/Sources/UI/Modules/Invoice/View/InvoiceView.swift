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
                String(localized: .Invoice.amount), value: $viewModel.amount, format: .number
            )
            .keyboardType(.decimalPad)
            Picker(data: $viewModel.currencyCode) { code in
                Text(code.identifier)
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
