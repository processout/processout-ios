//
//  ConfigurationView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 22.08.2024.
//

import SwiftUI

struct ConfigurationView: View {

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(.Configuration.project)) {
                    TextField(
                        String(localized: .Configuration.id),
                        text: $viewModel.state.projectId
                    )
                    TextField(
                        String(localized: .Configuration.privateKey),
                        text: $viewModel.state.projectKey
                    )
                    Picker(data: $viewModel.state.environments) { environment in
                        Text(environment.name)
                    } label: {
                        Text(.Configuration.environment)
                    }
                }
                Section(header: Text(.Configuration.customer)) {
                    TextField(
                        String(localized: .Configuration.id),
                        text: $viewModel.state.customerId
                    )
                }
                Section(header: Text(.Configuration.applePay)) {
                    TextField(
                        String(localized: .Configuration.merchantId),
                        text: $viewModel.state.merchantId
                    )
                }
                Button(String(localized: .Configuration.submit)) {
                    viewModel.submit()
                }
            }
            .onSubmit {
                viewModel.submit()
            }
            .navigationTitle(
                String(localized: .Configuration.title)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        action: {
                            isScannerPresented = true
                        },
                        label: {
                            Image(systemName: "qrcode.viewfinder")
                        }
                    )
                }
            }
            .sheet(isPresented: $isScannerPresented) {
                ConfigurationScannerView { code in
                    viewModel.didScanConfiguration(code)
                }
            }
        }
        .onReceive(viewModel.dismiss) {
            dismiss()
        }
        .onAppear(perform: viewModel.start)
    }

    // MARK: - Private Properties

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    private var viewModel = ConfigurationViewModel()

    @State
    private var isScannerPresented = false
}

#Preview {
    ConfigurationView()
}
