//
//  AlternativePaymentsView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import SwiftUI
import ProcessOutUI
import ProcessOut

@MainActor
struct AlternativePaymentsView: View {

    var body: some View {
        Form {
            if let viewModel = viewModel.state.message {
                MessageView(viewModel: viewModel)
            }
            InvoiceView(viewModel: $viewModel.state.invoice)
            Section {
                if let filters = viewModel.state.filter {
                    Picker(data: filters) { filter in
                        Text(filter.name)
                    } label: {
                        Text(.AlternativePayments.Filter.title)
                    }
                }
                if let gatewayConfigurations = Binding($viewModel.state.gatewayConfiguration) {
                    Picker(data: gatewayConfigurations) { configuration in
                        Text(configuration.name)
                    } label: {
                        Text(.AlternativePayments.gatewayConfiguration)
                    }
                }
                Picker(data: $viewModel.state.flow) { flow in
                    Text(flow.rawValue.capitalized)
                } label: {
                    Text(.AlternativePayments.flow)
                }
                Toggle(
                    String(localized: .AlternativePayments.nativePreference),
                    isOn: $viewModel.state.preferNative
                )
            } header: {
                Text(.AlternativePayments.gateway)
            }
            Button(String(localized: .AlternativePayments.pay)) {
                viewModel.pay()
            }
        }
        .onSubmit {
            viewModel.pay()
        }
        .refreshable {
            await viewModel.restart()
        }
        .onAppear(perform: viewModel.start)
        .sheet(item: $viewModel.state.nativePayment) { item in
            PONativeAlternativePaymentView(component: item.component)
        }
        .navigationTitle(String(localized: .AlternativePayments.title))
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private Properties

    @StateObject
    private var viewModel = AlternativePaymentsViewModel()
}
