//
//  ConfigurationViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 23.08.2024.
//

import SwiftUI
import Combine
@_spi(PO) import ProcessOut

@MainActor
final class ConfigurationViewModel: ObservableObject {

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
    @Published
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
            let projectId, projectKey, customerId, merchantId: String?
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let data = Data(rawValue.utf8)
            let configuration = try decoder.decode(Configuration.self, from: data)
            state.projectId = configuration.projectId ?? ""
            state.projectKey = configuration.projectKey ?? ""
            state.customerId = configuration.customerId ?? ""
            state.merchantId = configuration.merchantId ?? ""
            // Scanning configuration from QR is useful during development so environment is set to stage.
            state.environments.selection = .stage
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
        state.environments.selection = configuration.environment
        state.customerId = Constants.customerId
        state.merchantId = Constants.merchantId ?? ""
    }

    private func configureProcessOutWithCurrentState() {
        let configuration = ProcessOutConfiguration(
            projectId: state.projectId,
            privateKey: state.projectKey,
            environment: state.environments.selection
        )
        Constants.projectConfiguration = configuration
        Constants.customerId = state.customerId
        Constants.merchantId = state.merchantId
        ProcessOut.configure(configuration: configuration, force: true)
    }
}
