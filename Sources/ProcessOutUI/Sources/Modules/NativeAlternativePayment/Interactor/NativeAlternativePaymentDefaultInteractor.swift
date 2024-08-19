//
//  NativeAlternativePaymentDefaultInteractor.swift
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
    BaseInteractor<NativeAlternativePaymentInteractorState>, NativeAlternativePaymentInteractor {

    init(
        configuration: PONativeAlternativePaymentConfiguration,
        invoicesService: POInvoicesService,
        imagesRepository: POImagesRepository,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.logger = logger
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - Interactor

    let configuration: PONativeAlternativePaymentConfiguration
    weak var delegate: PONativeAlternativePaymentDelegate?

    override func start() {
        guard case .idle = state else {
            return
        }
        logger.info("Starting native alternative payment")
        send(event: .willStart)
        setStateUnchecked(.starting)
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
        setStateUnchecked(.started(startedState))
        didUpdate(parameter: parameter, to: formattedValue ?? "")
    }

    func submit() {
        guard case let .started(startedState) = state, startedState.areParametersValid else {
            return
        }
        willSubmit(parameters: startedState.parameters)
        do {
            let values = try validatedValues(for: startedState.parameters)
            setStateUnchecked(.submitting(snapshot: startedState))
            Task {
                await continueSubmissionUnchecked(startedState: startedState, values: values)
            }
        } catch {
            restoreStartedStateAfterSubmissionFailureIfPossible(error, replaceErrorMessages: false)
        }
    }

    override func cancel() {
        logger.debug("Will attempt to cancel payment.")
        switch state {
        case .started(let state) where state.isCancellable:
            setFailureStateUnchecked(error: POFailure(code: .cancelled))
        case .awaitingCapture(let state) where state.isCancellable:
            captureCancellable?.cancel()
        default:
            logger.debug("Ignored cancellation attempt from unsupported state: \(state)")
        }
    }

    func didRequestCancelConfirmation() {
        send(event: .didRequestCancelConfirmation)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let captureCompletionDelay: TimeInterval = 3
        static let emailRegex = #"^\S+@\S+$"#
        static let phoneRegex = #"^\+?\d{1,3}\d*$"#
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let imagesRepository: POImagesRepository
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    private var captureCancellable: AnyCancellable?

    // MARK: - Starting State

    private func continueStartUnchecked() async {
        let details: PONativeAlternativePaymentMethodTransactionDetails
        do {
            let request = PONativeAlternativePaymentMethodTransactionDetailsRequest(
                invoiceId: configuration.invoiceId, gatewayConfigurationId: configuration.gatewayConfigurationId
            )
            details = try await invoicesService.nativeAlternativePaymentMethodTransactionDetails(request: request)
        } catch {
            setFailureStateUnchecked(error: error)
            return
        }
        switch details.state {
        case .customerInput, nil:
            if details.parameters.isEmpty {
                logger.debug("Will set started state with empty inputs, this may be unexpected")
            }
            let startedState = State.Started(
                gateway: details.gateway,
                amount: details.invoice.amount,
                currencyCode: details.invoice.currencyCode,
                parameters: await createParameters(specifications: details.parameters),
                isCancellable: disableDuration(of: configuration.secondaryAction).isZero
            )
            setStateUnchecked(.started(startedState))
            send(event: .didStart)
            logger.info("Did start payment, waiting for parameters")
            enableCancellationAfterDelay()
        case .pendingCapture:
            logger.debug("No more parameters to submit, waiting for capture")
            await setAwaitingCaptureStateUnchecked(gateway: details.gateway, parameterValues: details.parameterValues)
        case .captured:
            await setCapturedStateUnchecked(gateway: details.gateway, parameterValues: details.parameterValues)
        case .failed:
            fallthrough // swiftlint:disable:this fallthrough
        @unknown default:
            let failure = POFailure(code: .generic(.mobile))
            setFailureStateUnchecked(error: failure)
        }
    }

    // MARK: - Submission State

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
        switch response.state {
        case .pendingCapture:
            send(event: .didSubmitParameters(additionalParametersExpected: false))
            await setAwaitingCaptureStateUnchecked(
                gateway: startedState.gateway, parameterValues: response.parameterValues
            )
        case .captured:
            send(event: .didSubmitParameters(additionalParametersExpected: false))
            await setCapturedStateUnchecked(
                gateway: startedState.gateway, parameterValues: response.parameterValues
            )
        case .customerInput:
            await restoreStartedStateAfterSubmission(nativeApm: response)
        case .failed:
            fallthrough // swiftlint:disable:this fallthrough
        @unknown default:
            let failure = POFailure(code: .generic(.mobile))
            setFailureStateUnchecked(error: failure)
        }
    }

    // MARK: - Awaiting Capture State

    private func setAwaitingCaptureStateUnchecked(
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway,
        parameterValues: PONativeAlternativePaymentMethodParameterValues?
    ) async {
        guard configuration.paymentConfirmation.waitsConfirmation else {
            logger.info("Won't await payment capture because waitsPaymentConfirmation is set to false")
            setSubmittedUnchecked()
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
            actionImage: actionImage,
            isCancellable: disableDuration(of: configuration.paymentConfirmation.secondaryAction).isZero,
            isDelayed: false
        )
        setStateUnchecked(.awaitingCapture(awaitingCaptureState))
        logger.info("Waiting for invoice capture confirmation")
        let request = PONativeAlternativePaymentCaptureRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            timeout: configuration.paymentConfirmation.timeout
        )
        let task = Task {
            do {
                try await invoicesService.captureNativeAlternativePayment(request: request)
                await setCapturedStateUnchecked(gateway: gateway, parameterValues: parameterValues)
            } catch {
                setFailureStateUnchecked(error: error)
            }
        }
        captureCancellable = AnyCancellable(task.cancel)
        enableCaptureCancellationAfterDelay()
        schedulePaymentConfirmationDelay()
    }

    private func schedulePaymentConfirmationDelay() {
        guard let timeInterval = configuration.paymentConfirmation.showProgressIndicatorAfter else {
            return
        }
        Task { [weak self] in
            try? await Task.sleep(seconds: timeInterval)
            guard let self, case .awaitingCapture(var awaitingCaptureState) = self.state else {
                return
            }
            awaitingCaptureState.isDelayed = true
            setStateUnchecked(.awaitingCapture(awaitingCaptureState))
        }
    }

    // MARK: - Captured State

    private func setCapturedStateUnchecked(
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway,
        parameterValues: PONativeAlternativePaymentMethodParameterValues?
    ) async {
        logger.info("Did receive invoice capture confirmation")
        guard configuration.paymentConfirmation.waitsConfirmation else {
            logger.info("Should't wait for confirmation, so setting submitted state instead of captured.")
            setSubmittedUnchecked()
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
        setStateUnchecked(.captured(capturedState))
        send(event: .didCompletePayment)
        if !configuration.skipSuccessScreen {
            try? await Task.sleep(seconds: Constants.captureCompletionDelay)
        }
        completion(.success(()))
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
        setStateUnchecked(.started(startedState))
        send(event: .didFailToSubmitParameters(failure: failure))
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update")
    }

    private func restoreStartedStateAfterSubmission(nativeApm: PONativeAlternativePaymentMethodResponse) async {
        guard case var .submitting(startedState) = state else {
            return
        }
        startedState.parameters = await createParameters(
            specifications: nativeApm.parameterDefinitions ?? []
        )
        setStateUnchecked(.started(startedState))
        send(event: .didSubmitParameters(additionalParametersExpected: true))
        logger.debug("More parameters are expected, waiting for parameters to update")
    }

    // MARK: - Submitted State

    private func setSubmittedUnchecked() {
        setStateUnchecked(.submitted)
        completion(.success(()))
    }

    // MARK: - Failure State

    private func setFailureStateUnchecked(error: Error) {
        logger.warn("Did fail to process native payment: \(error)")
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.debug("Unexpected error type: \(error)")
            failure = POFailure(code: .generic(.mobile), underlyingError: error)
        }
        setStateUnchecked(.failure(failure))
        send(event: .didFail(failure: failure))
        completion(.failure(failure))
    }

    // MARK: - Cancellation Availability

    private func enableCancellationAfterDelay() {
        let disabledFor = disableDuration(of: configuration.secondaryAction)
        guard disabledFor > 0 else {
            logger.debug("Cancel action is not set or initially enabled.")
            return
        }
        Task {
            try? await Task.sleep(seconds: disabledFor)
            switch state {
            case .started(var state):
                state.isCancellable = true
                setStateUnchecked(.started(state))
            case .submitting(var state):
                state.isCancellable = true
                setStateUnchecked(.submitting(snapshot: state))
            default:
                break
            }
        }
    }

    private func enableCaptureCancellationAfterDelay() {
        let disabledFor = disableDuration(of: configuration.paymentConfirmation.secondaryAction)
        guard disabledFor > 0 else {
            logger.debug("Confirmation cancel action is not set or initially enabled.")
            return
        }
        Task {
            try? await Task.sleep(seconds: disabledFor)
            guard case .awaitingCapture(var awaitingState) = state else {
                return
            }
            awaitingState.isCancellable = true
            setStateUnchecked(.awaitingCapture(awaitingState))
        }
    }

    // MARK: - Events

    @MainActor
    private func send(event: PONativeAlternativePaymentEvent) {
        logger.debug("Did send event: '\(event)'")
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    private func didUpdate(parameter: NativeAlternativePaymentInteractorState.Parameter, to value: String) {
        logger.debug("Did update parameter value '\(value)' for '\(parameter.specification.key)' key")
        let parametersChangedEvent = PONativeAlternativePaymentEvent.ParametersChanged(
            parameter: parameter.specification, value: value
        )
        send(event: .parametersChanged(parametersChangedEvent))
    }

    private func willSubmit(parameters: [NativeAlternativePaymentInteractorState.Parameter]) {
        logger.info("Will submit payment parameters")
        let values = Dictionary(grouping: parameters, by: \.specification.key)
            .compactMapValues(\.first?.value)
        let willSubmitParametersEvent = PONativeAlternativePaymentEvent.WillSubmitParameters(
            parameters: parameters.map(\.specification), values: values
        )
        send(event: .willSubmitParameters(willSubmitParametersEvent))
    }

    // MARK: - Utils

    private func setStateUnchecked(_ state: NativeAlternativePaymentInteractorState) {
        self.state = state
    }

    private func createParameters(
        specifications: [PONativeAlternativePaymentMethodParameter]
    ) async -> [NativeAlternativePaymentInteractorState.Parameter] {
        var parameters = specifications.map { specification in
            let formatter: Foundation.Formatter?
            switch specification.type {
            case .phone:
                formatter = PhoneNumberFormatter()
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
        let resource: StringResource
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
        guard !configuration.paymentConfirmation.hideGatewayDetails else {
            return nil
        }
        return gateway.logoUrl
    }

    private func disableDuration(of action: PONativeAlternativePaymentConfiguration.SecondaryAction?) -> TimeInterval {
        guard case .cancel(_, let disabledFor, _) = action else {
            return 0
        }
        return disabledFor
    }

    // MARK: - Default Values

    /// Updates parameters with default values.
    private func setDefaultValues(
        parameters: inout [NativeAlternativePaymentInteractorState.Parameter]
    ) async {
        guard !parameters.isEmpty else {
            return
        }
        let defaultValues = await delegate?.nativeAlternativePayment(
            defaultsFor: parameters.map(\.specification)
        ) ?? [:]
        for (offset, parameter) in parameters.enumerated() {
            let defaultValue: String?
            if let value = defaultValues[parameter.specification.key] {
                switch parameter.specification.type {
                case .singleSelect:
                    let availableValues = parameter.specification.availableValues?.map(\.value) ?? []
                    assert(availableValues.contains(value), "Unknown `singleSelect` parameter value.")
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
            var normalizedValue = parameter.value
            if case .phone = parameter.specification.type, let value = normalizedValue {
                normalizedValue = PhoneNumberFormatter().normalized(number: value)
            }
            if let normalizedValue, normalizedValue != parameter.value {
                logger.debug("Will use updated value '\(normalizedValue)' for key '\(parameter.specification.key)'")
            }
            if let invalidField = validate(value: normalizedValue ?? "", specification: parameter.specification) {
                invalidFields.append(invalidField)
            } else {
                validatedValues[parameter.specification.key] = normalizedValue
            }
        }
        if invalidFields.isEmpty {
            return validatedValues
        }
        throw POFailure(code: .validation(.general), invalidFields: invalidFields)
    }

    private func validate(
        value: String, specification: PONativeAlternativePaymentMethodParameter
    ) -> POFailure.InvalidField? {
        let message: String?
        if value.isEmpty {
            if specification.required {
                message = String(resource: .NativeAlternativePayment.Error.requiredParameter)
            } else {
                message = nil
            }
        } else if let length = specification.length, value.count != length {
            message = String(resource: .NativeAlternativePayment.Error.invalidLength, replacements: length)
        } else {
            switch specification.type {
            case .numeric where !CharacterSet(charactersIn: value).isSubset(of: .decimalDigits):
                message = String(resource: .NativeAlternativePayment.Error.invalidNumber)
            case .email where value.range(of: Constants.emailRegex, options: .regularExpression) == nil:
                message = String(resource: .NativeAlternativePayment.Error.invalidEmail)
            case .phone where value.range(of: Constants.phoneRegex, options: .regularExpression) == nil:
                message = String(resource: .NativeAlternativePayment.Error.invalidPhone)
            case .singleSelect where specification.availableValues?.map(\.value).contains(value) == false:
                message = String(resource: .NativeAlternativePayment.Error.invalidValue)
            default:
                message = nil
            }
        }
        return message.map { POFailure.InvalidField(name: specification.key, message: $0) }
    }
}

// swiftlint:enable file_length type_body_length
