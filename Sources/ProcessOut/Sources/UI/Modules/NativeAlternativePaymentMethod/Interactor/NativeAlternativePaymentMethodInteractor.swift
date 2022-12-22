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

    deinit {
        captureCancellable?.cancel()
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
            .map { isValid(value: updatedValues[$0.key], for: $0) }
            .allSatisfy { $0 }
        let updatedStartedState = State.Started(
            gatewayDisplayName: startedState.gatewayDisplayName,
            gatewayLogo: startedState.gatewayLogo,
            customerActionImageUrl: startedState.customerActionImageUrl,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentFailure: nil,
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
                let message = response.nativeApm.parameterValues?.message
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
                self?.restoreStartedStateAfterSubmissionFailure(failure)
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
    private var captureCancellable: POCancellableType?

    // MARK: - State Management

    private func setStartedStateUnchecked(
        details: PONativeAlternativePaymentMethodTransactionDetails, gatewayLogo: UIImage?
    ) {
        switch details.state {
        case .customerInput, nil:
            break
        case .pendingCapture:
            trySetAwaitingCaptureStateUnchecked(gatewayLogo: gatewayLogo, expectedActionMessage: nil, actionImage: nil)
            return
        case .captured:
            setCapturedStateUnchecked(gatewayLogo: gatewayLogo)
            return
        }
        if details.parameters.isEmpty {
            Logger.ui.debug("Will set started state with empty inputs, this may be unexpected.")
        }
        let startedState = State.Started(
            gatewayDisplayName: details.gateway.displayName,
            gatewayLogo: gatewayLogo,
            customerActionImageUrl: details.gateway.customerActionImageUrl,
            amount: details.invoice.amount,
            currencyCode: details.invoice.currencyCode,
            parameters: details.parameters,
            values: [:],
            recentFailure: nil,
            isSubmitAllowed: details.parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(startedState)
    }

    private func trySetAwaitingCaptureStateUnchecked(
        gatewayLogo: UIImage?, expectedActionMessage: String?, actionImage: UIImage?
    ) {
        guard configuration.waitsPaymentConfirmation else {
            state = .submitted
            return
        }
        let awaitingCaptureState = State.AwaitingCapture(
            gatewayLogoImage: gatewayLogo, expectedActionMessage: expectedActionMessage, actionImage: actionImage
        )
        state = .awaitingCapture(awaitingCaptureState)
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
                self?.state = .captureFailure(failure)
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
            Logger.ui.error("Can't change state to captured from current state.")
            return
        }
        let capturedState = State.Captured(gatewayLogo: gatewayLogo)
        self.state = .captured(capturedState)
    }

    private func setCapturedStateUnchecked(gatewayLogo: UIImage?) {
        let capturedState = State.Captured(gatewayLogo: gatewayLogo)
        self.state = .captured(capturedState)
    }

    private func restoreStartedStateAfterSubmissionFailure(_ failure: POFailure) {
        guard case let .submitting(startedState) = state else {
            return
        }
        guard let invalidFields = failure.invalidFields, !invalidFields.isEmpty else {
            state = .submissionFailure(failure)
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
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: startedState.parameters,
            values: updatedValues,
            recentFailure: failure,
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
            customerActionImageUrl: startedState.customerActionImageUrl,
            amount: startedState.amount,
            currencyCode: startedState.currencyCode,
            parameters: parameters,
            values: [:],
            recentFailure: nil,
            isSubmitAllowed: parameters.map { isValid(value: nil, for: $0) }.allSatisfy { $0 }
        )
        state = .started(updatedStartedState)
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
