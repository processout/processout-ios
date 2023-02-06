//
//  NativeAlternativePaymentMethodInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

import Foundation
import UIKit

// swiftlint:disable:next type_body_length
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
        invoicesService: POInvoicesServiceType,
        imagesRepository: POImagesRepositoryType,
        configuration: Configuration,
        logger: POLogger
    ) {
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.configuration = configuration
        self.logger = logger
        super.init(state: .idle)
    }

    deinit {
        captureCancellable?.cancel()
    }

    // MARK: - NativeAlternativePaymentMethodInteractorType

    override func start() {
        guard case .idle = state else {
            return
        }
        // swiftlint:disable:next line_length
        logger.info("Starting invoice \(configuration.invoiceId) payment using configuration \(configuration.gatewayConfigurationId)")
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
                self?.logger.error("Failed to start payment: \(failure)")
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
            .map { isValid(value: updatedValues[$0.key], for: $0) }
            .allSatisfy { $0 }
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            customerActionImageUrl: startedState.customerActionImageUrl,
            customerActionMessage: startedState.customerActionMessage,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentFailure: nil,
            isSubmitAllowed: isSubmitAllowed
        )
        state = .started(updatedStartedState)
        logger.debug("Did update parameter value '\(value ?? "nil")' for '\(key)' key")
        return true
    }

    func submit() {
        guard case let .started(startedState) = state, startedState.isSubmitAllowed else {
            return
        }
        logger.info("Will submit '\(configuration.invoiceId)' payment parameters")
        let request = PONativeAlternativePaymentMethodRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            parameters: startedState.values.compactMapValues(\.value)
        )
        state = .submitting(snapshot: startedState)
        invoicesService.initiatePayment(request: request) { [weak self] result in
            switch result {
            case let .success(response) where response.nativeApm.state == .pendingCapture:
                let message = startedState.customerActionMessage
                if let imageUrl = startedState.customerActionImageUrl {
                    self?.imagesRepository.image(url: imageUrl) { image in
                        self?.trySetAwaitingCaptureStateUnchecked(
                            gatewayLogo: startedState.gatewayLogo, expectedActionMessage: message, actionImage: image
                        )
                    }
                } else {
                    self?.trySetAwaitingCaptureStateUnchecked(
                        gatewayLogo: startedState.gatewayLogo, expectedActionMessage: message, actionImage: nil
                    )
                }
            case let .success(response) where response.nativeApm.state == .captured:
                self?.setCapturedState()
            case let .success(response):
                self?.restoreStartedStateAfterSubmission(nativeApm: response.nativeApm)
            case let .failure(failure):
                self?.restoreStartedStateAfterSubmissionFailureIfPossible(failure)
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let emailRegex = #"^\S+@\S+$"#
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesServiceType
    private let imagesRepository: POImagesRepositoryType
    private let configuration: Configuration
    private let logger: POLogger
    private var captureCancellable: POCancellableType?

    // MARK: - State Management

    private func setStartedStateUnchecked(
        details: PONativeAlternativePaymentMethodTransactionDetails, gatewayLogo: UIImage?
    ) {
        switch details.state {
        case .customerInput, nil:
            break
        case .pendingCapture:
            logger.debug("No more parameters to submit for '\(configuration.invoiceId), waiting for capture")
            trySetAwaitingCaptureStateUnchecked(
                gatewayLogo: gatewayLogo, expectedActionMessage: details.gateway.customerActionMessage, actionImage: nil
            )
            return
        case .captured:
            logger.info("Payment '\(configuration.invoiceId)' is already captured")
            self.state = .captured(.init(gatewayLogo: gatewayLogo))
            return
        }
        if details.parameters.isEmpty {
            logger.debug("Will set started state with empty inputs, this may be unexpected")
        }
        let startedState = State.Started(
            gatewayDisplayName: details.gateway.displayName,
            gatewayLogo: gatewayLogo,
            customerActionImageUrl: details.gateway.customerActionImageUrl,
            customerActionMessage: details.gateway.customerActionMessage,
            amount: details.invoice.amount,
            currencyCode: details.invoice.currencyCode,
            parameters: details.parameters,
            values: [:],
            recentFailure: nil,
            isSubmitAllowed: details.parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(startedState)
        logger.debug("Did start \(configuration.invoiceId) payment, waiting for parameters")
    }

    private func trySetAwaitingCaptureStateUnchecked(
        gatewayLogo: UIImage?, expectedActionMessage: String?, actionImage: UIImage?
    ) {
        guard configuration.waitsPaymentConfirmation else {
            logger.info("Won't await payment capture because waitsPaymentConfirmation is set to false")
            state = .submitted
            return
        }
        let awaitingCaptureState = State.AwaitingCapture(
            gatewayLogoImage: gatewayLogo, expectedActionMessage: expectedActionMessage, actionImage: actionImage
        )
        state = .awaitingCapture(awaitingCaptureState)
        logger.debug("Waiting for invoice \(configuration.invoiceId) capture confirmation")
        let request = PONativeAlternativePaymentCaptureRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            timeout: configuration.paymentConfirmationTimeout
        )
        captureCancellable = invoicesService.captureNativeAlternativePayment(request: request) { [weak self] result in
            switch result {
            case .success:
                self?.setCapturedState()
            case .failure(let failure):
                self?.logger.error("Did fail to capture invoice \(request.invoiceId): \(failure)")
                self?.state = .failure(failure)
            }
        }
    }

    private func setCapturedState() {
        let gatewayLogo: UIImage?
        switch state {
        case let .awaitingCapture(awaitingCaptureState):
            gatewayLogo = awaitingCaptureState.gatewayLogoImage
        case let .submitting(startedStateSnapshot):
            gatewayLogo = startedStateSnapshot.gatewayLogo
        default:
            return
        }
        let capturedState = State.Captured(gatewayLogo: gatewayLogo)
        self.state = .captured(capturedState)
        logger.debug("Did receive invoice '\(configuration.invoiceId)' capture confirmation")
    }

    private func restoreStartedStateAfterSubmissionFailureIfPossible(_ failure: POFailure) {
        logger.error("Did fail to submit parameters: \(failure)")
        guard case let .submitting(startedState) = state else {
            return
        }
        guard let invalidFields = failure.invalidFields, !invalidFields.isEmpty else {
            logger.debug("Submission error is not recoverable, aborting")
            state = .failure(failure)
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
            customerActionImageUrl: startedState.customerActionImageUrl,
            customerActionMessage: startedState.customerActionMessage,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentFailure: failure,
            isSubmitAllowed: false
        )
        self.state = .started(updatedStartedState)
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update")
    }

    private func restoreStartedStateAfterSubmission(nativeApm: PONativeAlternativePaymentMethodResponse.NativeApm) {
        guard case let .submitting(startedState) = state else {
            return
        }
        let parameters = nativeApm.parameterDefinitions ?? []
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            customerActionImageUrl: startedState.customerActionImageUrl,
            customerActionMessage: startedState.customerActionMessage,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: parameters,
            values: [:],
            recentFailure: nil,
            isSubmitAllowed: parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(updatedStartedState)
        logger.debug("More parameters are expected, waiting for parameters to update")
    }

    // MARK: - Utils

    private func isValid(
        value parameterValue: State.ParameterValue?, for parameter: PONativeAlternativePaymentMethodParameter
    ) -> Bool {
        guard let parameterValue, let value = parameterValue.value, !value.isEmpty else {
            return !parameter.required
        }
        if parameterValue.recentErrorMessage != nil {
            return false
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
