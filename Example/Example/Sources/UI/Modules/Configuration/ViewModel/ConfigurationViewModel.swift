//
//  ConfigurationViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.08.2024.
//

import SwiftUI
import Combine
@_spi(PO) import ProcessOut

@Observable
final class ConfigurationViewModel {

    init() {
        state = .idle
        dismissSubject = PassthroughSubject<Void, Never>()
    }

    // MARK: -

    /// Publisher that emits value when view model requires dismissal.
    var dismiss: AnyPublisher<Void, Never> {
        dismissSubject.eraseToAnyPublisher()
    }

    /// View model's state.
    var state: ConfigurationViewModelState

    func start() {
        updateStateWithExistingProcessOutConfiguration()
    }

    func submit() {
        configureProjectConstants()
        configureProcessOut()
        dismissSubject.send(())
    }

    // MARK: - Private Properties

    private let dismissSubject: PassthroughSubject<Void, Never>

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
        let configuration = ProcessOutConfiguration(
            projectId: state.projectId,
            privateKey: state.projectKey,
            environment: state.selectedEnvironment
        )
        ProcessOut.configure(configuration: configuration, force: true)
    }

    private func configureProjectConstants() {
        Constants.customerId = state.customerId
    }
}
