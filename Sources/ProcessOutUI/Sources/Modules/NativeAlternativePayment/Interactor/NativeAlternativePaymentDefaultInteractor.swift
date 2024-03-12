//
//  DefaultDynamicCheckoutAlternativePaymentInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 29.02.2024.
//

// swiftlint:disable file_length type_body_length

import Foundation
import SwiftUI
import Combine
@_spi(PO) import ProcessOut

final class NativeAlternativePaymentDefaultInteractor:
    BaseInteractor<NativeAlternativePaymentInteractorState>,
    NativeAlternativePaymentInteractor {

    init(
        configuration: PONativeAlternativePaymentConfiguration,
        delegate: PONativeAlternativePaymentDelegate?,
        invoicesService: POInvoicesService,
        imagesRepository: POImagesRepository,
        logger: POLogger
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.logger = logger
        super.init(state: .idle)
    }

    // MARK: - Interactor & Coordinator

    override func start() {
        guard case .idle = state else {
            return
        }
        logger.info(
            "Starting native alternative payment", attributes: ["GatewayId": configuration.gatewayConfigurationId]
        )
        send(event: .willStart)
        state = .starting
        Task {
            await continueStartUnchecked()
        }
    }

    func updateValue(_ value: String?, for key: String) {
        guard case var .started(startedState) = state else {
            logger.debug("Unable to update value in unsupported state: \(state)")
            return
        }
        // swiftlint:disable:next line_length
        guard let element = startedState.parameters.enumerated().first(where: { $0.element.specification.key == key }) else {
            logger.info("No value to update for key \(key)")
            return
        }
        var parameter = element.1
        let formattedValue = parameter.formatter?.string(for: value ?? "") ?? value
        guard parameter.value != formattedValue else {
            logger.debug("Ignored the same value for key: \(key)")
            return
        }
        parameter.value = formattedValue
        parameter.recentErrorMessage = nil
        startedState.parameters[element.0] = parameter
        state = .started(startedState)
        send(event: .parametersChanged)
        logger.debug("Did update parameter value '\(value ?? "nil")' for '\(key)' key")
    }

    func submit() {
        guard case let .started(startedState) = state, startedState.areParametersValid else {
            return
        }
        logger.info("Will submit payment parameters")
        send(event: .willSubmitParameters)
        do {
            let values = try validatedValues(for: startedState.parameters)
            state = .submitting(snapshot: startedState)
            Task {
                await continueSubmissionUnchecked(startedState: startedState, values: values)
            }
        } catch {
            restoreStartedStateAfterSubmissionFailureIfPossible(error, replaceErrorMessages: false)
        }
    }

    func cancel() {
        logger.debug("Will attempt to cancel payment.")
        switch state {
        case .started:
            setFailureStateUnchecked(error: POFailure(code: .cancelled))
        case .awaitingCapture:
            captureCancellable?.cancel()
        default:
            logger.debug("Ignored cancellation attempt from unsupported state: \(state)")
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let emailRegex = #"^\S+@\S+$"#
        static let phoneRegex = #"^\+?\d{1,3}\d*$"#
    }

    // MARK: - Private Properties

    private let configuration: PONativeAlternativePaymentConfiguration
    private let invoicesService: POInvoicesService
    private let imagesRepository: POImagesRepository
    private let logger: POLogger

    private var captureCancellable: AnyCancellable?
    private weak var delegate: PONativeAlternativePaymentDelegate?

    // MARK: - Starting State

    @MainActor
    private func continueStartUnchecked() async {
        let details: PONativeAlternativePaymentMethodTransactionDetails
        do {
            let request = PONativeAlternativePaymentMethodTransactionDetailsRequest(
                invoiceId: configuration.invoiceId, gatewayConfigurationId: configuration.gatewayConfigurationId
            )
            details = try await invoicesService.nativeAlternativePaymentMethodTransactionDetails(request: request)
        } catch {
            logger.info("Failed to start payment: \(error)")
            setFailureStateUnchecked(error: error)
            return
        }
        switch details.state {
        case .pendingCapture:
            logger.debug("No more parameters to submit, waiting for capture")
            await setAwaitingCaptureStateUnchecked(gateway: details.gateway, parameterValues: details.parameterValues)
        case .captured:
            await setCapturedStateUnchecked(gateway: details.gateway, parameterValues: details.parameterValues)
        default:
            if details.parameters.isEmpty {
                logger.debug("Will set started state with empty inputs, this may be unexpected")
            }
            let startedState = State.Started(
                gateway: details.gateway,
                amount: details.invoice.amount,
                currencyCode: details.invoice.currencyCode,
                parameters: await createParameters(specifications: details.parameters)
            )
            state = .started(startedState)
            send(event: .didStart)
            logger.info("Did start payment, waiting for parameters")
        }
    }

    // MARK: - Submission State

    @MainActor
    private func continueSubmissionUnchecked(
        startedState: NativeAlternativePaymentInteractorState.Started, values: [String: String]
    ) async {
        let request = PONativeAlternativePaymentMethodRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            parameters: values
        )
        let response: PONativeAlternativePaymentMethodResponse
        do {
            response = try await invoicesService.initiatePayment(request: request)
        } catch {
            restoreStartedStateAfterSubmissionFailureIfPossible(error, replaceErrorMessages: true)
            return
        }
        switch response.nativeApm.state {
        case .pendingCapture:
            send(event: .didSubmitParameters(additionalParametersExpected: false))
            await setAwaitingCaptureStateUnchecked(
                gateway: startedState.gateway, parameterValues: response.nativeApm.parameterValues
            )
        case .captured:
            send(event: .didSubmitParameters(additionalParametersExpected: false))
            await setCapturedStateUnchecked(
                gateway: startedState.gateway, parameterValues: response.nativeApm.parameterValues
            )
        default:
            await restoreStartedStateAfterSubmission(nativeApm: response.nativeApm)
        }
    }

    // MARK: - Awaiting Capture State

    @MainActor
    private func setAwaitingCaptureStateUnchecked(
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway,
        parameterValues: PONativeAlternativePaymentMethodParameterValues?
    ) async {
        guard configuration.waitsPaymentConfirmation else {
            logger.info("Won't await payment capture because waitsPaymentConfirmation is set to false")
            state = .submitted
            return
        }
        let actionMessage = parameterValues?.customerActionMessage ?? gateway.customerActionMessage
        send(event: .willWaitForCaptureConfirmation(additionalActionExpected: actionMessage != nil))
        let (logoImage, actionImage) = await imagesRepository.images(
            at: logoUrl(gateway: gateway, parameterValues: parameterValues), gateway.customerActionImageUrl
        )
        let awaitingCaptureState = State.AwaitingCapture(
            paymentProviderName: parameterValues?.providerName,
            logoImage: logoImage,
            actionMessage: actionMessage,
            actionImage: actionImage
        )
        state = .awaitingCapture(awaitingCaptureState)
        logger.info("Waiting for invoice capture confirmation")
        let request = PONativeAlternativePaymentCaptureRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            timeout: configuration.paymentConfirmationTimeout
        )
        let task = Task { @MainActor in
            do {
                try await invoicesService.captureNativeAlternativePayment(request: request)
                await setCapturedStateUnchecked(gateway: gateway, parameterValues: parameterValues)
            } catch {
                logger.error("Did fail to capture invoice: \(error)")
                setFailureStateUnchecked(error: error)
            }
        }
        captureCancellable = AnyCancellable(task.cancel)
    }

    // MARK: - Captured State

    @MainActor
    private func setCapturedStateUnchecked(
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway,
        parameterValues: PONativeAlternativePaymentMethodParameterValues?
    ) async {
        logger.info("Did receive invoice capture confirmation")
        guard configuration.waitsPaymentConfirmation else {
            logger.info("Should't wait for confirmation, so setting submitted state instead of captured.")
            state = .submitted
            return
        }
        let capturedState: State.Captured
        if case .awaitingCapture(let awaitingCaptureState) = state {
            capturedState = State.Captured(
                paymentProviderName: awaitingCaptureState.paymentProviderName, logoImage: awaitingCaptureState.logoImage
            )
        } else {
            let logoImage = await imagesRepository.image(
                at: logoUrl(gateway: gateway, parameterValues: parameterValues)
            )
            capturedState = State.Captured(paymentProviderName: parameterValues?.providerName, logoImage: logoImage)
        }
        state = .captured(capturedState)
        send(event: .didCompletePayment)
    }

    // MARK: - Started State Restoration

    private func restoreStartedStateAfterSubmissionFailureIfPossible(_ error: Error, replaceErrorMessages: Bool) {
        logger.info("Did fail to submit parameters: \(error)")
        guard let failure = error as? POFailure else {
            setFailureStateUnchecked(error: error)
            return
        }
        var startedState: State.Started
        switch state {
        case let .submitting(state), let .started(state):
            startedState = state
        default:
            return
        }
        let invalidFields = failure.invalidFields.map { invalidFields in
            Dictionary(grouping: invalidFields, by: \.name).compactMapValues(\.first)
        }
        guard let invalidFields = invalidFields, !invalidFields.isEmpty else {
            logger.debug("Submission error is not recoverable, aborting")
            setFailureStateUnchecked(error: failure)
            return
        }
        for (offset, parameter) in startedState.parameters.enumerated() {
            let errorMessage: String?
            if !replaceErrorMessages {
                errorMessage = invalidFields[parameter.specification.key]?.message
            } else if invalidFields[parameter.specification.key] != nil {
                errorMessage = self.errorMessage(parameterType: parameter.specification.type)
            } else {
                errorMessage = nil
            }
            startedState.parameters[offset].recentErrorMessage = errorMessage
        }
        self.state = .started(startedState)
        send(event: .didFailToSubmitParameters(failure: failure))
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update")
    }

    @MainActor
    private func restoreStartedStateAfterSubmission(
        nativeApm: PONativeAlternativePaymentMethodResponse.NativeApm
    ) async {
        guard case var .submitting(startedState) = state else {
            return
        }
        startedState.parameters = await createParameters(
            specifications: nativeApm.parameterDefinitions ?? []
        )
        state = .started(startedState)
        send(event: .didSubmitParameters(additionalParametersExpected: true))
        logger.debug("More parameters are expected, waiting for parameters to update")
    }

    // MARK: - Failure State

    private func setFailureStateUnchecked(error: Error) {
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.debug("Unexpected error type: \(error)")
            failure = POFailure(code: .generic(.mobile), underlyingError: error)
        }
        state = .failure(failure)
        send(event: .didFail(failure: failure))
    }

    // MARK: - Utils

    private func send(event: PONativeAlternativePaymentMethodEvent) {
        assert(Thread.isMainThread, "Method should be called on main thread.")
        logger.debug("Did send event: '\(event)'")
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    @MainActor
    private func createParameters(
        specifications: [PONativeAlternativePaymentMethodParameter]
    ) async -> [NativeAlternativePaymentInteractorState.Parameter] {
        var parameters = specifications.map { specification in
            let formatter: Foundation.Formatter?
            switch specification.type {
            case .phone:
                formatter = POPhoneNumberFormatter()
            default:
                formatter = nil
            }
            return State.Parameter(specification: specification, formatter: formatter)
        }
        await setDefaultValues(parameters: &parameters)
        return parameters
    }

    private func errorMessage(parameterType: PONativeAlternativePaymentMethodParameter.ParameterType) -> String {
        // Server doesn't support localized error messages, so local generic error
        // description is used instead in case particular field is invalid.
        // todo(andrii-vysotskyi): remove when backend is updated
        let resource: POStringResource
        switch parameterType {
        case .numeric:
            resource = .NativeAlternativePayment.Error.invalidNumber
        case .email:
            resource = .NativeAlternativePayment.Error.invalidEmail
        case .phone:
            resource = .NativeAlternativePayment.Error.invalidPhone
        default:
            resource = .NativeAlternativePayment.Error.invalidValue
        }
        return String(resource: resource)
    }

    private func logoUrl(
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway,
        parameterValues: PONativeAlternativePaymentMethodParameterValues?
    ) -> URL? {
        if parameterValues?.providerName != nil {
            return parameterValues?.providerLogoUrl
        }
        return gateway.logoUrl
    }

    // MARK: - Default Values

    /// Updates parameters with default values.
    @MainActor
    private func setDefaultValues(
        parameters: inout [NativeAlternativePaymentInteractorState.Parameter]
    ) async {
        guard !parameters.isEmpty else {
            return
        }
        let defaultValues = await delegate?.nativeAlternativePayment(
            defaultValuesFor: parameters.map(\.specification)
        )
        for (offset, parameter) in parameters.enumerated() {
            let defaultValue: String?
            if let value = defaultValues?[parameter.specification.key] {
                switch parameter.specification.type {
                case .singleSelect:
                    let availableValues = parameter.specification.availableValues?.map(\.value) ?? []
                    precondition(availableValues.contains(value), "Unknown `singleSelect` parameter value.")
                    defaultValue = value
                default:
                    defaultValue = parameter.formatter?.string(for: value) ?? value
                }
            } else {
                defaultValue = self.defaultValue(for: parameter)
            }
            parameters[offset].value = defaultValue
        }
    }

    private func defaultValue(for parameter: NativeAlternativePaymentInteractorState.Parameter) -> String? {
        if let formatter = parameter.formatter {
            return formatter.string(for: "")
        }
        if let availableValues = parameter.specification.availableValues {
            return availableValues.first { $0.default == true }?.value
        }
        return nil
    }

    // MARK: - Local Validation

    private func validatedValues(
        for parameters: [NativeAlternativePaymentInteractorState.Parameter]
    ) throws -> [String: String] {
        var validatedValues: [String: String] = [:]
        var invalidFields: [POFailure.InvalidField] = []
        parameters.forEach { parameter in
            let value = parameter.value
            let updatedValue: String? = {
                if case .phone = parameter.specification.type, let value {
                    return POPhoneNumberFormatter().normalized(number: value)
                }
                return value
            }()
            if let updatedValue, value != updatedValue {
                logger.debug("Will use updated value '\(updatedValue)' for key '\(parameter.specification.key)'")
            }
            if let invalidField = validate(parameter: parameter) {
                invalidFields.append(invalidField)
            } else {
                validatedValues[parameter.specification.key] = updatedValue
            }
        }
        if invalidFields.isEmpty {
            return validatedValues
        }
        throw POFailure(code: .validation(.general), invalidFields: invalidFields)
    }

    private func validate(
        parameter: NativeAlternativePaymentInteractorState.Parameter
    ) -> POFailure.InvalidField? {
        let value = parameter.value ?? ""
        let message: String?
        if value.isEmpty {
            if parameter.specification.required {
                message = String(resource: .NativeAlternativePayment.Error.requiredParameter)
            } else {
                message = nil
            }
        } else if let length = parameter.specification.length, value.count != length {
            message = String(resource: .NativeAlternativePayment.Error.invalidLength, replacements: length)
        } else {
            switch parameter.specification.type {
            case .numeric where !CharacterSet(charactersIn: value).isSubset(of: .decimalDigits):
                message = String(resource: .NativeAlternativePayment.Error.invalidNumber)
            case .email where value.range(of: Constants.emailRegex, options: .regularExpression) == nil:
                message = String(resource: .NativeAlternativePayment.Error.invalidEmail)
            case .phone where value.range(of: Constants.phoneRegex, options: .regularExpression) == nil:
                message = String(resource: .NativeAlternativePayment.Error.invalidPhone)
            case .singleSelect where parameter.specification.availableValues?.map(\.value).contains(value) == false:
                message = String(resource: .NativeAlternativePayment.Error.invalidValue)
            default:
                message = nil
            }
        }
        return message.map { POFailure.InvalidField(name: parameter.specification.key, message: $0) }
    }
}

// swiftlint:enable file_length type_body_length
