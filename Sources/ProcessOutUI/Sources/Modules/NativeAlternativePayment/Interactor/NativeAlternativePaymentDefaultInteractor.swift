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
        barcodeImageProvider: BarcodeImageProvider,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.barcodeImageProvider = barcodeImageProvider
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
        logger.info("Starting native alternative payment.")
        send(event: .willStart)
        let task = Task { @MainActor in
            do {
                let request = PONativeAlternativePaymentMethodTransactionDetailsRequest(
                    invoiceId: configuration.invoiceId,
                    gatewayConfigurationId: configuration.gatewayConfigurationId
                )
                let transactionDetails = try await invoicesService
                    .nativeAlternativePaymentMethodTransactionDetails(request: request)
                switch transactionDetails.state {
                case .customerInput, nil:
                    await setStartedState(transactionDetails: transactionDetails)
                case .pendingCapture:
                    await setAwaitingCaptureState(
                        with: transactionDetails.parameterValues, gateway: transactionDetails.gateway
                    )
                case .captured:
                    let paymentProvider = await paymentProvider(
                        with: transactionDetails.parameterValues, gateway: transactionDetails.gateway
                    )
                    setCapturedState(paymentProvider: paymentProvider)
                case .failed:
                    throw POFailure(
                        message: "A payment attempt was made previously and is currently in a failed state.",
                        code: .Mobile.generic
                    )
                @unknown default:
                    logger.error("Unexpected alternative payment state: \(transactionDetails.state.debugDescription).")
                    throw POFailure(message: "Something went wrong.", code: .Mobile.internal)
                }
            } catch {
                setFailureState(error: error)
            }
        }
        state = .starting(.init(task: task))
    }

    func updateValue(_ value: String?, for key: String) {
        guard case var .started(newState) = state else {
            logger.debug("Unable to update value in unsupported state: \(state).")
            return
        }
        let parameter = newState.parameters
            .enumerated()
            .first(where: { $0.element.specification.key == key })
        guard let parameter else {
            logger.info("No value to update for key \(key).")
            return
        }
        let formattedValue = parameter.element.formatter?.string(for: value ?? "") ?? value
        guard parameter.element.value != formattedValue else {
            logger.debug("Ignored the same value for key: \(key).")
            return
        }
        var updatedParameter = parameter.element
        updatedParameter.value = formattedValue
        updatedParameter.recentErrorMessage = nil
        newState.parameters[parameter.offset] = updatedParameter
        state = .started(newState)
        didUpdate(parameter: parameter.element, to: formattedValue ?? "")
    }

    // swiftlint:disable:next function_body_length
    func submit() {
        guard case let .started(currentState) = state else {
            logger.debug("Ignoring attempt to submit parameters in unsupported state: \(state).")
            return
        }
        guard currentState.areParametersValid else {
            logger.debug("Ignoring attempt to submit invalid parameters.")
            return
        }
        willSubmit(parameters: currentState.parameters)
        let values: [String: String]
        do {
            values = try validatedValues(for: currentState.parameters)
        } catch {
            attemptRecoverSubmissionError(error, replaceErrorMessages: false)
            return
        }
        let task = Task { @MainActor in
            do {
                let request = PONativeAlternativePaymentMethodRequest(
                    invoiceId: configuration.invoiceId,
                    gatewayConfigurationId: configuration.gatewayConfigurationId,
                    parameters: values
                )
                let response = try await invoicesService.initiatePayment(request: request)
                switch response.state {
                case .pendingCapture:
                    send(event: .didSubmitParameters(additionalParametersExpected: false))
                    await setAwaitingCaptureState(
                        with: response.parameterValues,
                        gateway: currentState.transactionDetails.gateway
                    )
                case .captured:
                    send(event: .didSubmitParameters(additionalParametersExpected: false))
                    let paymentProvider = await paymentProvider(
                        with: response.parameterValues,
                        gateway: currentState.transactionDetails.gateway
                    )
                    setCapturedState(paymentProvider: paymentProvider)
                case .customerInput:
                    await restoreStartedStateAfterSubmission(paymentResponse: response)
                case .failed:
                    throw POFailure(message: "The submitted parameters are not valid.", code: .Mobile.generic)
                @unknown default:
                    throw POFailure(
                        message: "Unexpected alternative payment state: \(response.state).", code: .Mobile.internal
                    )
                }
            } catch {
                attemptRecoverSubmissionError(error, replaceErrorMessages: true)
            }
        }
        state = .submitting(.init(snapshot: currentState, task: task))
    }

    func confirmCapture() {
        confirmCapture(force: false)
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .submitting(let currentState):
            currentState.task.cancel()
        case .awaitingCapture(let currentState):
            currentState.task?.cancel()
        case .captured(let currentState):
            // Intent here is not to cancel invocation of completion but to fast-forward
            // it by cancelling any ongoing delay operation if any.
            currentState.completionTask.cancel()
        default:
            break
        }
        setFailureState(error: POFailure(message: "Alternative payment has been canceled.", code: .Mobile.cancelled))
    }

    func didRequestCancelConfirmation() {
        send(event: .didRequestCancelConfirmation)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let emailRegex = #"^\S+@\S+$"#
        static let phoneRegex = #"^\+?\d{1,3}\d*$"#
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let imagesRepository: POImagesRepository
    private let barcodeImageProvider: BarcodeImageProvider
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - Starting State

    private func setStartedState(transactionDetails: PONativeAlternativePaymentMethodTransactionDetails) async {
        let parameters = await createParameters(specifications: transactionDetails.parameters)
        guard case .starting = state else {
            logger.debug("Ignoring attempt to set started state in unsupported state: \(state).")
            return
        }
        if transactionDetails.parameters.isEmpty {
            logger.debug("Will set started state with empty inputs, this may be unexpected.")
        }
        let startedState = State.Started(
            transactionDetails: transactionDetails,
            parameters: parameters,
            isCancellable: configuration.cancelButton?.disabledFor.isZero ?? true
        )
        state = .started(startedState)
        send(event: .didStart)
        logger.info("Did start payment, waiting for parameters.")
        enableCancellationAfterDelay()
    }

    private func enableCancellationAfterDelay() {
        guard let disabledFor = configuration.cancelButton?.disabledFor, disabledFor > 0 else {
            logger.debug("Cancel action is not set or initially enabled.")
            return
        }
        Task { @MainActor in
            try? await Task.sleep(seconds: disabledFor)
            switch state {
            case .started(var currentState):
                currentState.isCancellable = true
                state = .started(currentState)
            case .submitting(let currentState):
                var updatedSnapshot = currentState.snapshot
                updatedSnapshot.isCancellable = true
                state = .submitting(.init(snapshot: updatedSnapshot, task: currentState.task))
            default:
                break
            }
        }
    }

    // MARK: - Awaiting Capture State

    private func setAwaitingCaptureState(
        with parameterValues: PONativeAlternativePaymentMethodParameterValues?,
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway
    ) async {
        if configuration.paymentConfirmation.waitsConfirmation {
            do {
                let paymentProvider = await paymentProvider(with: parameterValues, gateway: gateway)
                let customerAction = try await customerAction(with: parameterValues, gateway: gateway)
                switch state {
                case .starting, .submitting:
                    break
                default:
                    logger.debug("Ignoring attempt to wait for capture from unsupported state.")
                    return
                }
                send(event: .willWaitForCaptureConfirmation(additionalActionExpected: customerAction != nil))
                // swiftlint:disable:next line_length
                let shouldConfirmCapture = customerAction != nil && configuration.paymentConfirmation.confirmButton != nil
                let awaitingCaptureState = State.AwaitingCapture(
                    paymentProvider: paymentProvider,
                    customerAction: customerAction,
                    isCancellable: configuration.paymentConfirmation.cancelButton?.disabledFor.isZero ?? true,
                    isDelayed: false,
                    shouldConfirmCapture: shouldConfirmCapture
                )
                state = .awaitingCapture(awaitingCaptureState)
                if !shouldConfirmCapture {
                    confirmCapture(force: true)
                }
                enableCaptureCancellationAfterDelay()
            } catch {
                setFailureState(error: error)
            }
        } else {
            logger.info("Payment capture wasn't requested, will attempt to set submitted state directly.")
            setSubmittedState()
        }
    }

    private func confirmCapture(force: Bool) {
        guard case .awaitingCapture(let currentState) = state else {
            logger.debug("Ignoring attempt to confirm capture from unsupported state: \(state).")
            return
        }
        guard currentState.shouldConfirmCapture || force else {
            logger.debug("Payment is already being captured, ignored.")
            return
        }
        if currentState.shouldConfirmCapture {
            delegate?.nativeAlternativePayment(didEmitEvent: .didConfirmPayment)
        }
        let request = PONativeAlternativePaymentCaptureRequest(
            invoiceId: configuration.invoiceId,
            gatewayConfigurationId: configuration.gatewayConfigurationId,
            timeout: configuration.paymentConfirmation.timeout
        )
        var newState = currentState
        newState.task = Task { @MainActor in
            do {
                try await invoicesService.captureNativeAlternativePayment(request: request)
                setCapturedState(paymentProvider: currentState.paymentProvider)
            } catch {
                setFailureState(error: error)
            }
        }
        newState.shouldConfirmCapture = false
        state = .awaitingCapture(newState)
        logger.info("Waiting for invoice capture confirmation.")
        schedulePaymentConfirmationDelay()
    }

    private func schedulePaymentConfirmationDelay() {
        guard let timeInterval = configuration.paymentConfirmation.showProgressViewAfter else {
            return
        }
        Task { @MainActor in
            try? await Task.sleep(seconds: timeInterval)
            guard case .awaitingCapture(var newState) = state else {
                return
            }
            newState.isDelayed = true
            state = .awaitingCapture(newState)
        }
    }

    private func customerAction(
        with parameterValues: PONativeAlternativePaymentMethodParameterValues?,
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway
    ) async throws -> NativeAlternativePaymentInteractorState.CaptureCustomerAction? {
        // todo(andrii-vysotskyi): decide if `null` customer action should be allowed
        let message = parameterValues?.customerActionMessage ?? gateway.customerActionMessage
        guard let message else {
            return nil
        }
        if let barcode = parameterValues?.customerActionBarcode {
            let minimumSize = CGSize(width: 250, height: 250)
            let image = barcodeImageProvider.image(for: barcode, minimumSize: minimumSize)
            if image == nil {
                throw POFailure(message: "Unable to generate barcode image.", code: .Mobile.internal)
            }
            return .init(message: message, image: image, barcodeType: barcode.type)
        }
        let image = await imagesRepository.image(at: gateway.customerActionImageUrl)
        return .init(message: message, image: image, barcodeType: nil)
    }

    // MARK: - Captured State

    private func setCapturedState(paymentProvider: NativeAlternativePaymentInteractorState.PaymentProvider) {
        guard !state.isSink else {
            logger.debug("Already in a sink state, ignoring attempt to set captured state.")
            return
        }
        let task = Task { @MainActor in
            if let success = configuration.success {
                // Sleep errors are ignored. The goal is that if this task is cancelled we should still
                // invoke completion.
                try? await Task.sleep(seconds: success.duration)
            }
            completion(.success(()))
        }
        state = .captured(.init(paymentProvider: paymentProvider, completionTask: task))
        send(event: .didCompletePayment)
    }

    private func setSubmittedState() {
        guard !state.isSink else {
            logger.debug("Already in a sink state, ignoring attempt to set submitted state.")
            return
        }
        state = .submitted
        completion(.success(()))
    }

    // MARK: - Submission Recovery

    private func attemptRecoverSubmissionError(_ error: Error, replaceErrorMessages: Bool) {
        logger.info("Did fail to submit parameters: \(error)")
        guard let failure = error as? POFailure else {
            setFailureState(error: error)
            return
        }
        var newState: State.Started
        switch state {
        case let .started(state):
            newState = state
        case let .submitting(state):
            newState = state.snapshot
        default:
            logger.debug("Ignoring attempt to recover submission error from unsupported state: \(state).")
            return
        }
        let invalidFields = failure.invalidFields.map { invalidFields in
            Dictionary(grouping: invalidFields, by: \.name).compactMapValues(\.first)
        }
        guard let invalidFields = invalidFields, !invalidFields.isEmpty else {
            logger.debug("Submission error is not recoverable, aborting.")
            setFailureState(error: failure)
            return
        }
        for (offset, parameter) in newState.parameters.enumerated() {
            let errorMessage: String?
            if !replaceErrorMessages {
                errorMessage = invalidFields[parameter.specification.key]?.message
            } else if invalidFields[parameter.specification.key] != nil {
                errorMessage = self.errorMessage(parameterType: parameter.specification.type)
            } else {
                errorMessage = nil
            }
            newState.parameters[offset].recentErrorMessage = errorMessage
        }
        state = .started(newState)
        send(event: .didFailToSubmitParameters(failure: failure))
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update.")
    }

    // MARK: - Submission Completion

    private func restoreStartedStateAfterSubmission(paymentResponse: PONativeAlternativePaymentMethodResponse) async {
        guard case let .submitting(currentState) = state else {
            return
        }
        var newState = currentState.snapshot
        newState.parameters = await createParameters(specifications: paymentResponse.parameterDefinitions ?? [])
        state = .started(newState)
        send(event: .didSubmitParameters(additionalParametersExpected: true))
        logger.debug("More parameters are expected, waiting for parameters to update.")
    }

    // MARK: - Failure State

    private func setFailureState(error: Error) {
        guard !state.isSink else {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(error).")
            return
        }
        logger.warn("Did fail to process native payment: \(error)")
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.error("Unexpected error type: \(error)")
            failure = POFailure(message: "Something went wrong.", code: .Mobile.generic, underlyingError: error)
        }
        state = .failure(failure)
        send(event: .didFail(failure: failure))
        completion(.failure(failure))
    }

    // MARK: - Cancellation Availability

    private func enableCaptureCancellationAfterDelay() {
        guard let disabledFor = configuration.paymentConfirmation.cancelButton?.disabledFor, disabledFor > 0 else {
            logger.debug("Confirmation cancel action is not set or initially enabled.")
            return
        }
        Task { @MainActor in
            try? await Task.sleep(seconds: disabledFor)
            guard case .awaitingCapture(var newState) = state else {
                return
            }
            newState.isCancellable = true
            state = .awaitingCapture(newState)
        }
    }

    // MARK: - Events

    private func send(event: PONativeAlternativePaymentMethodEvent) {
        assert(Thread.isMainThread, "Method should be called on main thread.")
        logger.debug("Did send event: '\(event)'")
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    private func didUpdate(parameter: NativeAlternativePaymentInteractorState.Parameter, to value: String) {
        logger.debug("Did update parameter value '\(value)' for '\(parameter.specification.key)' key.")
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

    private func paymentProvider(
        with parameterValues: PONativeAlternativePaymentMethodParameterValues?,
        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway
    ) async -> NativeAlternativePaymentInteractorState.PaymentProvider {
        if let parameterValues {
            if let url = parameterValues.providerLogoUrl, let image = await imagesRepository.image(at: url) {
                return .init(name: nil, image: image)
            }
            if let name = parameterValues.providerName {
                return .init(name: name, image: nil)
            }
        }
        guard !configuration.paymentConfirmation.hideGatewayDetails else {
            return .init(name: nil, image: nil)
        }
        let gatewayLogoImage = await imagesRepository.image(at: gateway.logoUrl)
        return .init(name: nil, image: gatewayLogoImage)
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
            defaultValuesFor: parameters.map(\.specification)
        ) ?? [:]
        for (offset, parameter) in parameters.enumerated() {
            let defaultValue: String?
            if let value = defaultValues[parameter.specification.key] {
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
            var normalizedValue = parameter.value
            if case .phone = parameter.specification.type, let value = normalizedValue {
                normalizedValue = POPhoneNumberFormatter().normalized(number: value)
            }
            if let normalizedValue, normalizedValue != parameter.value {
                logger.debug("Will use updated value '\(normalizedValue)' for key '\(parameter.specification.key)'.")
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
        throw POFailure(
            message: "Submitted parameters are not valid.",
            code: .RequestValidation.general,
            invalidFields: invalidFields
        )
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
