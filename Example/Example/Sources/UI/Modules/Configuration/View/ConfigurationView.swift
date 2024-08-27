//
//  ConfigurationView.swift
//  Example
//
//  Created by Andrii Vysotskyi on 22.08.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut

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
                    Picker(selection: $viewModel.state.selectedEnvironment) {
                        ForEach(viewModel.state.environments) { environment in
                            Text(environment.name)
                        }
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
                VStack {
                    ConfigurationScannerView { code in
                        viewModel.didScanConfiguration(code)
                    }
                    Spacer()
                }
                .presentationCornerRadius(16)
                .presentationDragIndicator(.visible)
                .presentationDetents([.fraction(0.5)])
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

    @State
    private var viewModel = ConfigurationViewModel()

    @State
    private var isScannerPresented = false
}

#Preview {
    ConfigurationView()
}
