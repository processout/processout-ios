//
//  ApplePayView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.08.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutUI

struct ApplePayView: View {

    var body: some View {
        Form {
            if let viewModel = viewModel.state.message {
                MessageView(viewModel: viewModel)
            }
            InvoiceView(viewModel: $viewModel.state.invoice)
            Button(String(localized: .ApplePay.pay)) {
                viewModel.pay()
            }
        }
        .onSubmit {
            viewModel.pay()
        }
        .navigationTitle(String(localized: .ApplePay.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @State
    private var viewModel = ApplePayViewModel()
}

#Preview {
    ApplePayView()
}
