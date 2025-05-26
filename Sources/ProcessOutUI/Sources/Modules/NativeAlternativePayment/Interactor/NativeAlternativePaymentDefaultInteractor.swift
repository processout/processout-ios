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
    weak var delegate: PONativeAlternativePaymentDelegateV2?

    override func start() {
        guard case .idle = state else {
            return
        }
        logger.info("Starting native alternative payment.")
        send(event: .willStart)
        let task = Task { @MainActor in
            do {
                let request = PONativeAlternativePaymentRequest(
                    invoiceId: configuration.invoiceId,
                    gatewayConfigurationId: configuration.gatewayConfigurationId
                )
                let payment = try await invoicesService.nativeAlternativePayment(request: request)
                await setState(with: payment)
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
        let values: [String: PONativeAlternativePaymentAuthorizationRequestV2.Parameter]
        do {
            values = try validatedValues(for: currentState.parameters)
        } catch {
            attemptRecoverSubmissionError(error, replaceErrorMessages: false)
            return
        }
        let task = Task { @MainActor in
            do {
                let request = PONativeAlternativePaymentAuthorizationRequestV2(
                    invoiceId: configuration.invoiceId,
                    gatewayConfigurationId: configuration.gatewayConfigurationId,
                    parameters: values
                )
                let payment = try await invoicesService.authorizeInvoice(request: request)
                switch payment.state {
                case .nextStepRequired:
                    send(event: .didSubmitParameters(.init(additionalParametersExpected: true)))
                case .captured, .pendingCapture:
                    send(event: .didSubmitParameters(.init(additionalParametersExpected: false)))
                default:
                    preconditionFailure("Unexpected payment state.")
                }
                await setState(with: payment)
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

    // MARK: - State Handling

    private func setState(with payment: PONativeAlternativePaymentAuthorizationResponseV2) async {
        switch payment.state {
        case .nextStepRequired:
            switch payment.nextStep {
            case .submitData(let nextStep):
                await setStartedState(nextStep: nextStep)
            case .redirect(let nextStep):
                // todo(andrii-vysotskyi): revise state handling
                let newState = State.AwaitingRedirect(redirect: nextStep)
                state = .awaitingRedirect(newState)
            default:
                let failure = POFailure(message: "Unsupported next step.", code: .Mobile.generic)
                setFailureState(error: failure)
            }
        case .pendingCapture where configuration.paymentConfirmation.waitsConfirmation:
            await setAwaitingCaptureState(payment: payment)
        case .pendingCapture:
            logger.info("Payment capture wasn't requested, will attempt to set submitted state directly.")
            setSubmittedState()
        case .captured:
            await setCapturedState(payment: payment)
        default:
            logger.error("Unexpected alternative payment state: \(payment.state).")
            let failure = POFailure(message: "Something went wrong.", code: .Mobile.generic)
            setFailureState(error: failure)
        }
    }

    // MARK: - Starting State

    private func setStartedState(nextStep: PONativeAlternativePaymentNextStepV2.SubmitData) async {
        let parameters = await createParameters(specifications: nextStep.parameters.parameterDefinitions)
        switch state {
        case .starting, .submitting, .redirecting:
            break // todo(andrii-vysotskyi): check if more states should be supported
        default:
            logger.debug("Ignoring attempt to set started state in unsupported state: \(state).")
            return
        }
        if nextStep.parameters.parameterDefinitions.isEmpty {
            logger.info("Will set started state with empty inputs, this may be unexpected.")
        }
        let startedState = State.Started(
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

    private func setAwaitingCaptureState(payment: PONativeAlternativePaymentAuthorizationResponseV2) async {
        do {
            let customerInstructions = try await resolve(customerInstructions: payment.customerInstructions)
            switch state {
            case .starting, .submitting, .redirecting:
                break
            default:
                logger.debug("Ignoring attempt to wait for capture from unsupported state.")
                return
            }
            // todo(andrii-vysotskyi): fix event
            // send(event: .willWaitForCaptureConfirmation(additionalActionExpected: customerAction != nil))
            // swiftlint:disable:next line_length
            let shouldConfirmCapture = !customerInstructions.isEmpty && configuration.paymentConfirmation.confirmButton != nil
            let awaitingCaptureState = State.AwaitingCapture(
                customerInstructions: customerInstructions,
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
        var newState = currentState
        newState.task = Task { @MainActor [configuration] in
            do {
                let request = PONativeAlternativePaymentRequest(
                    invoiceId: configuration.invoiceId,
                    gatewayConfigurationId: configuration.gatewayConfigurationId,
                    captureConfirmation: .init(timeout: configuration.paymentConfirmation.timeout)
                )
                let response = try await invoicesService.nativeAlternativePayment(request: request)
                await setState(with: response)
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

    // MARK: - Captured State

    private func setCapturedState(payment: PONativeAlternativePaymentAuthorizationResponseV2) async {
        do {
            let resolvedCustomerInstructions = try await resolve(customerInstructions: payment.customerInstructions)
            guard !state.isSink else {
                logger.debug("Already in a sink state, ignoring attempt to set captured state.")
                return
            }
            // todo(andrii-vysotskyi): decide what to do with success screen where there are instructions
            let task = Task { @MainActor in
                if let success = configuration.success {
                    // Sleep errors are ignored. The goal is that if this task is cancelled we should still
                    // invoke completion.
                    try? await Task.sleep(seconds: success.duration)
                }
                completion(.success(()))
            }
            state = .captured(
                .init(customerInstructions: resolvedCustomerInstructions, completionTask: task)
            )
            send(event: .didCompletePayment)
        } catch {
            setFailureState(error: error)
        }
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
                errorMessage = self.errorMessage(parameter: parameter.specification)
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

    private func restoreStartedStateAfterSubmission(payment: PONativeAlternativePaymentAuthorizationResponseV2) async {
        guard case let .submitting(currentState) = state else {
            return
        }
        switch payment.nextStep {
        case .submitData(let nextStep):
            var newState = currentState.snapshot
            newState.parameters = await createParameters(specifications: nextStep.parameters.parameterDefinitions)
            state = .started(newState)
            send(event: .didSubmitParameters(.init(additionalParametersExpected: true)))
            logger.debug("More parameters are expected, waiting for parameters to update.")
        case .redirect:
            break // todo(andrii-vysotskyi): redirect to somewhere
        default:
            let failure = POFailure(message: "Unable to proceed with unknown next step.", code: .Mobile.generic)
            setFailureState(error: failure)
        }
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

    private func send(event: PONativeAlternativePaymentEventV2) {
        logger.debug("Did send event: '\(event)'")
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    private func didUpdate(parameter: NativeAlternativePaymentInteractorState.Parameter, to value: String) {
        logger.debug("Did update parameter value '\(value)' for '\(parameter.specification.key)' key.")
        let parametersChangedEvent = PONativeAlternativePaymentEventV2.ParametersChanged(
            parameter: parameter.specification, value: value
        )
        send(event: .parametersChanged(parametersChangedEvent))
    }

    private func willSubmit(parameters: [NativeAlternativePaymentInteractorState.Parameter]) {
        logger.info("Will submit payment parameters")
        let values = Dictionary(grouping: parameters, by: \.specification.key)
            .compactMapValues(\.first?.value)
        let willSubmitParametersEvent = PONativeAlternativePaymentEventV2.WillSubmitParameters(
            parameters: parameters.map(\.specification), values: values
        )
        send(event: .willSubmitParameters(willSubmitParametersEvent))
    }

    // MARK: - Utils

    private func createParameters(
        specifications: [PONativeAlternativePaymentNextStepV2.SubmitData.Parameter]
    ) async -> [NativeAlternativePaymentInteractorState.Parameter] {
        var parameters = specifications.map { specification in
            let formatter: Foundation.Formatter?
            switch specification {
            case .phoneNumber:
                formatter = POPhoneNumberFormatter()
            default:
                formatter = nil
            }
            return State.Parameter(specification: specification, formatter: formatter)
        }
        await setDefaultValues(parameters: &parameters)
        return parameters
    }

    private func errorMessage(
        parameter: PONativeAlternativePaymentNextStepV2.SubmitData.Parameter
    ) -> String {
        // Server doesn't support localized error messages, so local generic error
        // description is used instead in case particular field is invalid.
        // todo(andrii-vysotskyi): remove when backend is updated
        // todo(andrii-vysotskyi): support new parameter types
        let resource: POStringResource
        switch parameter {
        case .digits, .otp:
            resource = .NativeAlternativePayment.Error.invalidNumber
        case .email:
            resource = .NativeAlternativePayment.Error.invalidEmail
        case .phoneNumber:
            resource = .NativeAlternativePayment.Error.invalidPhone
        default:
            resource = .NativeAlternativePayment.Error.invalidValue
        }
        return String(resource: resource)
    }

//    private func paymentProvider(
//        with parameterValues: PONativeAlternativePaymentMethodParameterValues?,
//        gateway: PONativeAlternativePaymentMethodTransactionDetails.Gateway
//    ) async -> NativeAlternativePaymentInteractorState.PaymentProvider {
//        if let parameterValues {
//            if let url = parameterValues.providerLogoUrl, let image = await imagesRepository.image(at: url) {
//                return .init(name: nil, image: image)
//            }
//            if let name = parameterValues.providerName {
//                return .init(name: name, image: nil)
//            }
//        }
//        guard !configuration.paymentConfirmation.hideGatewayDetails else {
//            return .init(name: nil, image: nil)
//        }
//        let gatewayLogoImage = await imagesRepository.image(at: gateway.logoUrl)
//        return .init(name: nil, image: gatewayLogoImage)
//    }

    // MARK: - Customer Instructions

    private func resolve(
        customerInstructions: [PONativeAlternativePaymentCustomerInstructionV2]?
    ) async throws -> [NativeAlternativePaymentResolvedCustomerInstruction] {
        var resolvedInstructions: [NativeAlternativePaymentResolvedCustomerInstruction] = []
        for instruction in customerInstructions ?? [] {
            resolvedInstructions.append(try await resolve(customerInstruction: instruction))
        }
        return resolvedInstructions
    }

    private func resolve(
        customerInstruction: PONativeAlternativePaymentCustomerInstructionV2
    ) async throws -> NativeAlternativePaymentResolvedCustomerInstruction {
        switch customerInstruction {
        case .barcode(let barcode):
            let minimumSize = CGSize(width: 250, height: 250)
            let image = barcodeImageProvider.image(for: barcode.value, minimumSize: minimumSize)
            guard let image else {
                throw POFailure(message: "Unable to generate barcode image.", code: .Mobile.internal)
            }
            return .barcode(.init(image: image, type: barcode.value.type))
        case .text(let text):
            return .text(.init(label: text.label, value: text.value))
        case .image(let image):
            guard let image = await imagesRepository.image(resource: image.value) else {
                throw POFailure(message: "Unable to prepare customer instruction image.", code: .Mobile.internal)
            }
            return .image(image)
        case .group(let group):
            let resolvedInstructions = try await resolve(customerInstructions: group.instructions)
            return .group(.init(label: group.label, instructions: resolvedInstructions))
        default:
            throw POFailure(message: "Unable to resolve unknown customer instruction.", code: .Mobile.generic)
        }
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
        )
        for (offset, parameter) in parameters.enumerated() {
            let defaultValue: String?
            if let value = defaultValues?[parameter.specification.key] {
                switch parameter.specification {
                case .singleSelect(let specification):
                    let availableValues = specification.availableValues.map(\.value)
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
        if case .singleSelect(let specification) = parameter.specification {
            return specification.preselectedValue?.value
        }
        return nil
    }

    // MARK: - Local Validation

    private func validatedValues(
        for parameters: [NativeAlternativePaymentInteractorState.Parameter]
    ) throws -> [String: PONativeAlternativePaymentAuthorizationRequestV2.Parameter] {
        var validatedValues: [String: PONativeAlternativePaymentAuthorizationRequestV2.Parameter] = [:]
        var invalidFields: [POFailure.InvalidField] = []
        parameters.forEach { parameter in
            var normalizedValue = parameter.value
            if case .phoneNumber = parameter.specification, let value = normalizedValue {
                normalizedValue = POPhoneNumberFormatter().normalized(number: value)
            }
            if let normalizedValue, normalizedValue != parameter.value {
                logger.debug("Will use updated value '\(normalizedValue)' for key '\(parameter.specification.key)'.")
            }
            if let invalidField = validate(value: normalizedValue ?? "", specification: parameter.specification) {
                invalidFields.append(invalidField)
            } else if let normalizedValue {
                validatedValues[parameter.specification.key] = .string(normalizedValue)
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
        value: String, specification: PONativeAlternativePaymentNextStepV2.SubmitData.Parameter
    ) -> POFailure.InvalidField? {
        if value.isEmpty, specification.required {
            let errorMessage = String(resource: .NativeAlternativePayment.Error.requiredParameter)
            return .init(name: specification.key, message: errorMessage)
        }
        var errorMessage: String?
        switch specification {
        case .card(let parameter):
            if validateLength(
                of: value, min: parameter.minLength, max: parameter.maxLength, errorMessage: &errorMessage
            ) {
                return nil
            }
        case .otp(let parameter):
            if validateLength(
                of: value, min: parameter.minLength, max: parameter.maxLength, errorMessage: &errorMessage
            ) {
                return nil
            }
        case .text, .singleSelect, .boolean, .digits, .phoneNumber, .email:
            return nil // No additional validation
        case .unknown:
            assertionFailure("Unable to validate unknown parameter.")
            return nil
        }
        if let errorMessage {
            return .init(name: specification.key, message: errorMessage)
        }
        return nil
    }

    private func validateLength(of value: String, min: Int?, max: Int?, errorMessage: inout String?) -> Bool {
        if let min, value.count < min {
            errorMessage = String(resource: .NativeAlternativePayment.Error.invalidLength, replacements: min)
            return false
        }
        if let max, value.count > max {
            errorMessage = String(resource: .NativeAlternativePayment.Error.invalidLength, replacements: max)
            return false
        }
        return true
    }
}

// swiftlint:enable file_length type_body_length
