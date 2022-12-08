//
//  NativeAlternativePaymentMethodInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation
import class UIKit.UIImage

final class NativeAlternativePaymentMethodInteractor:
    BaseInteractor<NativeAlternativePaymentMethodInteractorState>, NativeAlternativePaymentMethodInteractorType {

    struct Configuration {

        /// Gateway configuration id.
        let gatewayConfigurationId: String

        /// Invoice identifier.
        let invoiceId: String

        /// Indicates whether interactor should wait for payment confirmation or not.
        let waitsPaymentConfirmation: Bool

        /// Maximum amount of time to wait for payment confirmation if it is enabled.
        let paymentConfirmationTimeout: TimeInterval
    }

    init(
        invoicesService: POInvoicesServiceType, imagesRepository: POImagesRepositoryType, configuration: Configuration
    ) {
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.configuration = configuration
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
        let request = PONativeAlternativePaymentMethodTransactionDetailsRequest(
            invoiceId: configuration.invoiceId, gatewayConfigurationId: configuration.gatewayConfigurationId
        )
        invoicesService.nativeAlternativePaymentMethodTransactionDetails(request: request) { [weak self] result in
            switch result {
            case let .success(details):
                self?.imagesRepository.image(url: details.gateway.logoUrl) { [weak self] image in
                    self?.setStartedStateUnchecked(details: details, gatewayLogo: image)
                }
            case .failure(let failure):
                self?.state = .failure(failure)
            }
        }
    }

    func updateValue(_ value: String?, for key: String) -> Bool {
        guard case let .started(startedState) = state, startedState.values[key]?.value != value else {
            return false
        }
        var updatedValues = startedState.values
        updatedValues[key] = .init(value: value, recentErrorMessage: nil)
        let isSubmitAllowed = startedState.parameters
            .map { isValid(value: updatedValues[$0.key]?.value, for: $0) }
            .allSatisfy { $0 }
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentErrorMessage: nil,
            isSubmitAllowed: isSubmitAllowed
        )
        state = .started(updatedStartedState)
        return true
    }

    func submit() {
        guard case let .started(startedState) = state, startedState.isSubmitAllowed else {
            return
        }
        let request = PONativeAlternativePaymentMethodRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            parameters: startedState.values.compactMapValues(\.value)
        )
        state = .submitting(snapshot: startedState)
        invoicesService.initiatePayment(request: request) { [weak self] result in
            switch result {
            case let .success(response) where response.nativeApm.state == .pendingCapture:
                self?.trySetAwaitingCaptureStateUnchecked(
                    gatewayLogo: startedState.gatewayLogo,
                    expectedActionMessage: response.nativeApm.parameterValues?.message
                )
            case let .success(response):
                self?.restoreStartedStateAfterSubmission(nativeApm: response.nativeApm)
            case let .failure(failure):
                self?.restoreStartedStateAfterSubmissionFailure(failure)
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let maximumCaptureTimeout: TimeInterval = 180
        static let emailRegex = #"^\S+@\S+$"#
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesServiceType
    private let imagesRepository: POImagesRepositoryType
    private let configuration: Configuration

    // MARK: - State Management

    private func setStartedStateUnchecked(
        details: PONativeAlternativePaymentMethodTransactionDetails, gatewayLogo: UIImage?
    ) {
        switch details.state {
        case .customerInput, nil:
            break
        case .pendingCapture:
            trySetAwaitingCaptureStateUnchecked(gatewayLogo: gatewayLogo, expectedActionMessage: nil)
            return
        }
        if details.parameters.isEmpty {
            Logger.ui.debug("Will set started state without empty inputs, this may be unexpected.")
        }
        let startedState = State.Started(
            gatewayDisplayName: details.gateway.displayName,
            gatewayLogo: gatewayLogo,
            amount: details.invoice.amount,
            currencyCode: details.invoice.currencyCode,
            parameters: details.parameters,
            values: [:],
            recentErrorMessage: nil,
            isSubmitAllowed: details.parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(startedState)
    }

    private func trySetAwaitingCaptureStateUnchecked(gatewayLogo: UIImage?, expectedActionMessage: String?) {
        guard configuration.waitsPaymentConfirmation else {
            state = .submitted
            return
        }
        let awaitingCaptureState = State.AwaitingCapture(
            gatewayLogo: gatewayLogo, expectedActionMessage: nil
        )
        state = .awaitingCapture(awaitingCaptureState)
        let captureTimeout = min(Constants.maximumCaptureTimeout, configuration.paymentConfirmationTimeout)
        let timer = Timer.scheduledTimer(withTimeInterval: captureTimeout, repeats: false) { [weak self] _ in
            self?.state = .captureTimeout
        }
        var completion: ((Result<Void, POFailure>) -> Void)! // swiftlint:disable:this implicitly_unwrapped_optional
        completion = { [weak self, invoicesService, configuration] result in
            guard let self, timer.isValid else {
                return
            }
            switch result {
            case .success:
                timer.invalidate()
                self.setCapturedState()
            case .failure:
                invoicesService.capture(invoiceId: configuration.invoiceId, completion: completion)
            }
        }
        invoicesService.capture(invoiceId: configuration.invoiceId, completion: completion)
    }

    private func setCapturedState() {
        guard case let .awaitingCapture(awaitingCaptureState) = state else {
            Logger.ui.error("Can't change state to captured from current state.")
            return
        }
        let capturedState = State.Captured(gatewayLogo: awaitingCaptureState.gatewayLogo)
        self.state = .captured(capturedState)
    }

    private func restoreStartedStateAfterSubmissionFailure(_ failure: POFailure) {
        guard case let .submitting(startedState) = state else {
            return
        }
        var updatedValues: [String: State.ParameterValue] = [:]
        startedState.values.forEach { key, value in
            let errorMessage = failure.invalidFields?.first { $0.name == key }?.message
            updatedValues[key] = State.ParameterValue(value: value.value, recentErrorMessage: errorMessage)
        }
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentErrorMessage: failure.message,
            isSubmitAllowed: false
        )
        self.state = .started(updatedStartedState)
    }

    private func restoreStartedStateAfterSubmission(nativeApm: PONativeAlternativePaymentMethodResponse.NativeApm) {
        guard case let .submitting(startedState) = state else {
            return
        }
        let parameters = nativeApm.parameterDefinitions ?? []
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: parameters,
            values: [:],
            recentErrorMessage: nil,
            isSubmitAllowed: parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(updatedStartedState)
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
            return value.range(of: Constants.emailRegex, options: .regularExpression) != nil
        case .phone:
            return true
        }
    }
}
