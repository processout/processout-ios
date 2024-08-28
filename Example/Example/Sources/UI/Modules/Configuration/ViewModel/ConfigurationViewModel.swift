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
        configureProcessOutWithCurrentState()
        dismissSubject.send(())
    }

    func didScanConfiguration(_ rawValue: String) {
        struct Configuration: Decodable {
            let projectId, projectKey, customerId: String
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let data = Data(rawValue.utf8)
            let configuration = try decoder.decode(Configuration.self, from: data)
            state.projectId = configuration.projectId
            state.projectKey = configuration.projectKey
            state.customerId = configuration.customerId
            configureProcessOutWithCurrentState()
        } catch {
            // Errors are ignored
        }
    }

    // MARK: - Private Properties

    private let dismissSubject: PassthroughSubject<Void, Never>

    // MARK: - Private Methods

    private func updateStateWithExistingProcessOutConfiguration() {
        let configuration = Constants.projectConfiguration
        state.projectId = configuration.projectId
        state.projectKey = configuration.privateKey ?? ""
        state.selectedEnvironment = configuration.environment
        state.customerId = Constants.customerId
    }

    private func configureProcessOutWithCurrentState() {
        let configuration = ProcessOutConfiguration(
            projectId: state.projectId,
            privateKey: state.projectKey,
            environment: state.selectedEnvironment
        )
        Constants.projectConfiguration = configuration
        Constants.customerId = state.customerId
        ProcessOut.configure(configuration: configuration, force: true)
    }
}
