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
}

#Preview {
    ConfigurationView()
}
