//
//  NativeAlternativePaymentMethodInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation

final class NativeAlternativePaymentMethodInteractor:
    BaseInteractor<NativeAlternativePaymentMethodInteractorState>, NativeAlternativePaymentMethodInteractorType {

    init(
        gatewayConfigurationsRepository: POGatewayConfigurationsRepositoryType,
        invoicesRepository: POInvoicesRepositoryType,
        gatewayConfigurationId: String,
        invoiceId: String
    ) {
        self.gatewayConfigurationsRepository = gatewayConfigurationsRepository
        self.invoicesRepository = invoicesRepository
        self.gatewayConfigurationId = gatewayConfigurationId
        self.invoiceId = invoiceId
        super.init(state: .idle)
    }

    // MARK: - NativeAlternativePaymentMethodInteractorType

    override func start() {
        switch state {
        case .idle, .failure:
            break
        default:
            return
        }
        state = .starting
        let request = POFindGatewayConfigurationRequest(id: gatewayConfigurationId, expands: .gateway)
        gatewayConfigurationsRepository.find(request: request) { [weak self] result in
            switch result {
            case let .success(gatewayConfiguration):
                self?.setStartedStateUnchecked(gatewayConfiguration: gatewayConfiguration)
            case .failure:
                self?.state = .failure
            }
        }
    }

    func updateValue(_ value: String?, for key: String) -> Bool {
        let startedState: State.Started
        switch state {
        case let .started(state), let .submissionFailure(state, _):
            startedState = state
        default:
            return false
        }
        guard let parameter = startedState.parameters.first(where: { $0.key == key }) else {
            Logger.ui.error("Parameter is not available for key '\(key)'.")
            return false
        }
        var updatedValues = startedState.values
        updatedValues[key] = .init(
            value: value, isValid: isValid(value: value, for: parameter)
        )
        let updatedStartedState = State.Started(
            message: startedState.message,
            parameters: startedState.parameters,
            values: updatedValues,
            isSubmitAllowed: areValuesValid(updatedValues, parameters: startedState.parameters)
        )
        state = .started(updatedStartedState)
        return true
    }

    func submit() {
        let startedState: State.Started
        switch state {
        case let .started(state), let .submissionFailure(state, _):
            startedState = state
        default:
            return
        }
        guard startedState.isSubmitAllowed else {
            return
        }
        let request = PONativeAlternativePaymentMethodRequest(
            invoiceId: invoiceId,
            gatewayConfigurationId: gatewayConfigurationId,
            parameters: startedState.values.compactMapValues(\.value)
        )
        state = .submitting(snapshot: startedState)
        invoicesRepository.initiatePayment(request: request) { [weak self] result in
            switch result {
            case let .success(response):
                self?.trySetSubmittedStateUnchecked(startedState: startedState, response: response)
            case let .failure(failure):
                self?.setSubmissionFailureState(startedState: startedState, failure: failure)
            }
        }
    }

    // MARK: - Private Properties

    private let gatewayConfigurationsRepository: POGatewayConfigurationsRepositoryType
    private let invoicesRepository: POInvoicesRepositoryType
    private let gatewayConfigurationId: String
    private let invoiceId: String

    // MARK: - State Management

    private func setStartedStateUnchecked(gatewayConfiguration: POGatewayConfiguration) {
        guard let configuration = gatewayConfiguration.gateway?.nativeApmConfig else {
            state = .failure
            return
        }
        let startedState = State.Started(
            message: nil,
            parameters: configuration.parameters,
            values: [:],
            isSubmitAllowed: areValuesValid(nil, parameters: configuration.parameters)
        )
        state = .started(startedState)
    }

    private func trySetSubmittedStateUnchecked(
        startedState: State.Started, response: PONativeAlternativePaymentMethodResponse
    ) {
        if case .pendingCapture = response.nativeApm.state {
            state = .submitted(snapshot: startedState)
            return
        }
        guard let parameters = response.nativeApm.parameterDefinitions, !parameters.isEmpty else {
            state = .failure
            return
        }
        let updatedStartedState = State.Started(
            message: response.nativeApm.parameterValues?.message,
            parameters: parameters,
            values: [:],
            isSubmitAllowed: areValuesValid(nil, parameters: parameters)
        )
        state = .started(updatedStartedState)
    }

    private func setSubmissionFailureState(startedState: State.Started, failure: PORepositoryFailure) {
        state = .submissionFailure(snapshot: startedState, failure: failure)
    }

    // MARK: - Utils

    private func isValid(value: String?, for parameter: PONativeAlternativePaymentMethodParameter) -> Bool {
        guard let value, !value.isEmpty else {
            return !parameter.required
        }
        if let length = parameter.length, value.count != length {
            return false
        }
        switch parameter.type {
        case .numeric:
            return CharacterSet(charactersIn: value).isSubset(of: .decimalDigits)
        case .text:
            return CharacterSet(charactersIn: value).isSubset(of: .alphanumerics)
        case .email:
            return value.range(of: #"^\S+@\S+$"#, options: .regularExpression) != nil
        case .phone:
            return true
        }
    }

    private func areValuesValid(
        _ values: [String: State.ParameterValue]?, parameters: [PONativeAlternativePaymentMethodParameter]
    ) -> Bool {
         parameters.map { values?[$0.key]?.isValid ?? isValid(value: nil, for: $0) }.allSatisfy { $0 }
    }
}
