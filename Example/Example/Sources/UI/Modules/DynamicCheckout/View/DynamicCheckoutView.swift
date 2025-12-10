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
            Section {
                Picker(data: $viewModel.state.authenticationService) { service in
                    Text(service.rawValue.capitalized)
                } label: {
                    Text(.DynamicCheckout.threeDSService)
                }
            }
            Button(String(localized: .DynamicCheckout.pay)) {
                viewModel.pay()
            }
        }
        .sheet(item: $viewModel.state.dynamicCheckout) { item in
            PODynamicCheckoutView(
                configuration: item.configuration,
                delegate: item.delegate,
                completion: item.completion
            )
            // Using the sheet modifier interferes with the default ScrollView behavior,
            // preventing it from canceling subview interactions during a scroll.
            // Adding a drag gesture is a workaround to resolve this issue.
            .gesture(DragGesture(minimumDistance: 0))
        }
        .onSubmit {
            viewModel.pay()
        }
        .navigationTitle(String(localized: .DynamicCheckout.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel = DynamicCheckoutViewModel()
}

#Preview {
    DynamicCheckoutView()
}
