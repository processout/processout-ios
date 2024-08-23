//
//  ConfigurationViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.08.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut

@Observable
final class ConfigurationViewModel {

    init() {
        state = .idle
    }

    // MARK: -

    var state: ConfigurationViewModelState! // swiftlint:disable:this implicitly_unwrapped_optional

    func start() {
        updateStateWithExistingProcessOutConfiguration()
    }

    func submit() {
        configureProcessOut()
        state.areFeaturesPresented = true
    }

    // MARK: - Private Methods

    private func updateStateWithExistingProcessOutConfiguration() {
        guard ProcessOut.isConfigured else {
            return
        }
        let configuration = ProcessOut.shared.configuration
        state.projectId = configuration.projectId
        state.projectKey = configuration.privateKey ?? ""
        state.selectedEnvironment = configuration.environment
        state.customerId = Constants.customerId
    }

    private func configureProcessOut() {
        // todo(andrii-vysotskyi): set customer ID
        let configuration = ProcessOutConfiguration(
            projectId: state.projectId,
            privateKey: state.projectKey,
            environment: state.selectedEnvironment
        )
        ProcessOut.configure(configuration: configuration, force: true)
    }
}
