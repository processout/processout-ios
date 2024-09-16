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
            HStack {
                TextField(
                    String(localized: .Invoice.id), text: $viewModel.id
                )
                .keyboardType(.asciiCapable)
                Button(
                    action: {
                        isScannerPresented = true
                    },
                    label: {
                        Image(systemName: "qrcode.viewfinder")
                    }
                )
            }
            .sheet(isPresented: $isScannerPresented) {
                ConfigurationScannerView { invoiceId in
                    viewModel.id = invoiceId
                }
            }
            TextField(
                String(localized: .Invoice.amount), value: $viewModel.amount, format: .number
            )
            .keyboardType(.decimalPad)
            TextField(
                String(localized: .Invoice.currency), text: $viewModel.currencyCode
            )
            .keyboardType(.asciiCapable)
        } header: {
            Text(.Invoice.title)
        }
    }

    // MARK: - Private Properties

    @Binding
    private var viewModel: InvoiceViewModel

    @State
    private var isScannerPresented = false
}
