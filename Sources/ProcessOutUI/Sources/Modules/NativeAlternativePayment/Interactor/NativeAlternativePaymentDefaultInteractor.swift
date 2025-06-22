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
        serviceAdapter: NativeAlternativePaymentServiceAdapter,
        imagesRepository: POImagesRepository,
        barcodeImageProvider: BarcodeImageProvider,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.serviceAdapter = serviceAdapter
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
                let request = NativeAlternativePaymentServiceAdapterRequest(flow: configuration.flow)
                let payment = try await serviceAdapter.continuePayment(with: request)
                try await setState(with: payment)
            } catch {
                setFailureState(error: error)
            }
        }
        state = .starting(.init(task: task))
    }

    func updateValue(_ value: PONativeAlternativePaymentParameterValue, for key: String) {
        guard case var .started(newState) = state else {
            logger.debug("Unable to update value in unsupported state: \(state).")
            return
        }
        guard let parameter = newState.parameters[key], parameter.value != value else {
            logger.info("No value to update for key \(key).")
            return
        }
        var updatedParameter = parameter
        updatedParameter.value = value
        updatedParameter.recentErrorMessage = nil
        newState.parameters[key] = updatedParameter
        state = .started(newState)
        didUpdate(parameter: parameter, to: value)
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
        willSubmit(parameters: Array(currentState.parameters.values))
        let values: [String: PONativeAlternativePaymentSubmitDataV2.Parameter]
        do {
            values = try validatedValues(for: Array(currentState.parameters.values))
        } catch {
            attemptRecoverSubmissionError(error, replaceErrorMessages: false)
            return
        }
        let task = Task { @MainActor in
            do {
                let request = NativeAlternativePaymentServiceAdapterRequest(
                    flow: configuration.flow, submitData: .init(parameters: values)
                )
                let payment = try await serviceAdapter.continuePayment(with: request)
                switch payment.state {
                case .nextStepRequired:
                    send(event: .didSubmitParameters(.init(additionalParametersExpected: true)))
                    logger.debug("More parameters are expected, waiting for parameters to update.")
                case .success, .pending:
                    send(event: .didSubmitParameters(.init(additionalParametersExpected: false)))
                default:
                    preconditionFailure("Unexpected payment state.")
                }
                try await setState(with: payment)
            } catch {
                attemptRecoverSubmissionError(error, replaceErrorMessages: true)
            }
        }
        state = .submitting(.init(snapshot: currentState, task: task))
    }

    func confirmPayment() {
        confirmPayment(force: false)
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .submitting(let currentState):
            currentState.task.cancel()
        case .awaitingCompletion(let currentState):
            currentState.task?.cancel()
        case .completed(let currentState):
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

    // MARK: - Private Properties

    private let serviceAdapter: NativeAlternativePaymentServiceAdapter
    private let imagesRepository: POImagesRepository
    private let barcodeImageProvider: BarcodeImageProvider
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - State Handling

    private func setState(with response: NativeAlternativePaymentServiceAdapterResponse) async throws {
        switch response.state {
        case .nextStepRequired:
            if let redirect = response.redirect {
                let newState = State.AwaitingRedirect(paymentMethod: response.paymentMethod, redirect: redirect)
                state = .awaitingRedirect(newState)
            } else if let elements = response.elements {
                try await setStartedState(paymentMethod: response.paymentMethod, elements: elements)
            } else {
                let failure = POFailure(message: "Unsupported next step.", code: .Mobile.generic)
                setFailureState(error: failure)
            }
        case .pending:
            await setAwaitingCompletionState(response: response)
        case .success:
            await setCompletedState(response: response)
        default:
            logger.error("Unexpected alternative payment state: \(response.state).")
            let failure = POFailure(message: "Something went wrong.", code: .Mobile.generic)
            setFailureState(error: failure)
        }
    }

    // MARK: - Starting State

    private func setStartedState(
        paymentMethod: PONativeAlternativePaymentMethodV2, elements: [PONativeAlternativePaymentElementV2]
    ) async throws {
        let parameters = await createParameters(for: elements)
        switch state {
        case .starting, .submitting, .redirecting:
            break // todo(andrii-vysotskyi): check if more states should be supported
        default:
            logger.debug("Ignoring attempt to set started state in unsupported state: \(state).")
            return
        }
        if parameters.isEmpty {
            logger.info("Will set started state with empty inputs, this may be unexpected.")
        }
        let startedState = State.Started(
            paymentMethod: paymentMethod,
            elements: try await resolve(elements: elements),
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

    // MARK: - Awaiting Completion State

    private func setAwaitingCompletionState(response: NativeAlternativePaymentServiceAdapterResponse) async {
        if case .awaitingCompletion(let currentState) = state, !currentState.shouldConfirmPayment {
            let failure = POFailure(code: .Mobile.generic)
            setFailureState(error: failure)
            return
        }
        do {
            let resolvedElements = try await resolve(elements: response.elements ?? [])
            switch state {
            case .starting, .submitting, .redirecting:
                break
            default:
                logger.debug("Ignoring attempt to wait for payment confirmation from unsupported state.")
                return
            }
            send(event: .willWaitForPaymentConfirmation(.init()))
            let shouldConfirmPayment =
                !resolvedElements.isEmpty && configuration.paymentConfirmation.confirmButton != nil
            let awaitingPaymentCompletionState = State.AwaitingCompletion(
                paymentMethod: response.paymentMethod,
                elements: resolvedElements,
                estimatedCompletionDate: nil,
                isCancellable: configuration.paymentConfirmation.cancelButton?.disabledFor.isZero ?? true,
                shouldConfirmPayment: shouldConfirmPayment
            )
            state = .awaitingCompletion(awaitingPaymentCompletionState)
            if !shouldConfirmPayment {
                confirmPayment(force: true)
            }
            enablePaymentConfirmationCancellationAfterDelay()
        } catch {
            setFailureState(error: error)
        }
    }

    private func confirmPayment(force: Bool) {
        guard case .awaitingCompletion(let currentState) = state else {
            logger.debug("Ignoring attempt to confirm payment from unsupported state: \(state).")
            return
        }
        guard currentState.shouldConfirmPayment || force else {
            logger.debug("Payment was already confirmed, ignored.")
            return
        }
        if currentState.shouldConfirmPayment {
            delegate?.nativeAlternativePayment(didEmitEvent: .didConfirmPayment)
        }
        var newState = currentState
        newState.task = Task { @MainActor [configuration] in
            do {
                let request = NativeAlternativePaymentServiceAdapterRequest(flow: configuration.flow)
                let response = try await serviceAdapter.expectPaymentCompletion(with: request)
                try await setState(with: response)
            } catch {
                setFailureState(error: error)
            }
        }
        newState.estimatedCompletionDate = Date().addingTimeInterval(configuration.paymentConfirmation.timeout)
        newState.shouldConfirmPayment = false
        state = .awaitingCompletion(newState)
        logger.info("Waiting for payment completion confirmation.")
    }

    // MARK: - Completed State

    private func setCompletedState(response: NativeAlternativePaymentServiceAdapterResponse) async {
        do {
            let resolvedElements = try await resolve(elements: response.elements ?? [])
            guard !state.isSink else {
                logger.debug("Already in a sink state, ignoring attempt to set completed state.")
                return
            }
            let task = Task { @MainActor in
                if let success = configuration.success {
                    // Sleep errors are ignored. The goal is that if this task is
                    // cancelled we should still invoke completion.
                    // todo(andrii-vysotskyi): make configurable
                    let shouldConfirm = !resolvedElements.isEmpty
                    try? await Task.sleep(seconds: shouldConfirm ? 5 * 60 : success.duration)
                }
                completion(.success(()))
            }
            let newState = State.Completed(
                paymentMethod: response.paymentMethod,
                elements: resolvedElements,
                completionTask: task,
            )
            state = .completed(newState)
            send(event: .didCompletePayment)
        } catch {
            setFailureState(error: error)
        }
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
        for parameter in newState.parameters.values {
            let errorMessage: String?
            if !replaceErrorMessages {
                errorMessage = invalidFields[parameter.specification.key]?.message
            } else if invalidFields[parameter.specification.key] != nil {
                errorMessage = self.errorMessage(parameter: parameter.specification)
            } else {
                errorMessage = nil
            }
            newState.parameters[parameter.specification.key]?.recentErrorMessage = errorMessage
        }
        state = .started(newState)
        send(event: .didFailToSubmitParameters(failure: failure))
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update.")
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
        // todo(andrii-vysotskyi): add payment state to failure event
        send(event: .didFail(.init(failure: failure)))
        completion(.failure(failure))
    }

    // MARK: - Cancellation Availability

    private func enablePaymentConfirmationCancellationAfterDelay() {
        guard let disabledFor = configuration.paymentConfirmation.cancelButton?.disabledFor, disabledFor > 0 else {
            logger.debug("Confirmation cancel action is not set or initially enabled.")
            return
        }
        Task { @MainActor in
            try? await Task.sleep(seconds: disabledFor)
            guard case .awaitingCompletion(var newState) = state else {
                return
            }
            newState.isCancellable = true
            state = .awaitingCompletion(newState)
        }
    }

    // MARK: - Events

    private func send(event: PONativeAlternativePaymentEventV2) {
        logger.debug("Did send event: '\(event)'")
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    private func didUpdate(
        parameter: NativeAlternativePaymentInteractorState.Parameter,
        to value: PONativeAlternativePaymentParameterValue
    ) {
        logger.debug("Did update parameter value '\(value)' for '\(parameter.specification.key)' key.")
        let parametersChangedEvent = PONativeAlternativePaymentEventV2.ParametersChanged(
            parameter: parameter.specification
        )
        send(event: .parametersChanged(parametersChangedEvent))
    }

    private func willSubmit(parameters: [NativeAlternativePaymentInteractorState.Parameter]) {
        logger.info("Will submit payment parameters")
        let willSubmitParametersEvent = PONativeAlternativePaymentEventV2.WillSubmitParameters(
            parameters: parameters.map(\.specification)
        )
        send(event: .willSubmitParameters(willSubmitParametersEvent))
    }

    // MARK: - Utils

    private func createParameters(
        for elements: [PONativeAlternativePaymentElementV2]
    ) async -> [String: NativeAlternativePaymentInteractorState.Parameter] {
        let parameters = elements.flatMap { element -> [State.Parameter] in
            guard case let .form(form) = element else {
                return []
            }
            let parameters = form.parameters.parameterDefinitions.map { specification in
                let formatter: Foundation.Formatter? = switch specification {
                case .card:
                    POCardNumberFormatter()
                default:
                    nil
                }
                return State.Parameter(specification: specification, formatter: formatter)
            }
            return parameters
        }
        var groupedParameters = Dictionary(grouping: parameters, by: \.specification.key).compactMapValues(\.first)
        await setDefaultValues(parameters: &groupedParameters)
        return groupedParameters
    }

    private func errorMessage(
        parameter: PONativeAlternativePaymentFormV2.Parameter
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
        group: PONativeAlternativePaymentInstructionsGroupV2
    ) async throws -> NativeAlternativePaymentResolvedElement.Group {
        var resolvedInstructions: [NativeAlternativePaymentResolvedElement.Instruction] = []
        for instruction in group.instructions {
            resolvedInstructions.append(try await resolve(customerInstruction: instruction))
        }
        return .init(label: group.label, instructions: resolvedInstructions)
    }

    private func resolve(
        customerInstruction: PONativeAlternativePaymentCustomerInstructionV2
    ) async throws -> NativeAlternativePaymentResolvedElement.Instruction {
        switch customerInstruction {
        case .barcode(let barcode):
            let minimumSize = CGSize(width: 250, height: 250)
            let image = barcodeImageProvider.image(for: barcode.value, minimumSize: minimumSize)
            guard let image else {
                throw POFailure(message: "Unable to generate barcode image.", code: .Mobile.internal)
            }
            return .barcode(.init(image: image, type: barcode.value.type))
        case .message(let message):
            return .message(.init(label: message.label, value: message.value))
        case .image(let image):
            guard let image = await imagesRepository.image(resource: image.value) else {
                throw POFailure(message: "Unable to prepare customer instruction image.", code: .Mobile.internal)
            }
            return .image(image)
        default:
            throw POFailure(message: "Unable to resolve unknown customer instruction.", code: .Mobile.generic)
        }
    }

    // MARK: - Element

    private func resolve(
        elements: [PONativeAlternativePaymentElementV2]
    ) async throws -> [NativeAlternativePaymentResolvedElement] {
        var resolvedElements: [NativeAlternativePaymentResolvedElement] = []
        for element in elements {
            if let resolvedElement = try await resolve(element: element) {
                resolvedElements.append(resolvedElement)
            }
        }
        return resolvedElements
    }

    private func resolve(
        element: PONativeAlternativePaymentElementV2
    ) async throws -> NativeAlternativePaymentResolvedElement? {
        switch element {
        case .form(let form):
            for parameter in form.parameters.parameterDefinitions {
                if case .unknown = parameter {
                    throw POFailure(message: "Unable to proceed with unknown parameter.", code: .Mobile.generic)
                }
            }
            return .form(form)
        case .customerInstruction(let instruction):
            return .instruction(try await resolve(customerInstruction: instruction))
        case .group(let group):
            return .group(try await resolve(group: group))
        case .unknown:
            return nil
        }
    }

    // MARK: - Default Values

    /// Updates parameters with default values.
    private func setDefaultValues(
        parameters: inout [String: NativeAlternativePaymentInteractorState.Parameter]
    ) async {
        guard !parameters.isEmpty else {
            return
        }
        let defaultValues = await delegate?.nativeAlternativePayment(
            defaultValuesFor: parameters.values.map(\.specification)
        )
        for parameter in parameters.values {
            parameters[parameter.specification.key]?.value = defaultValue(
                for: parameter, fallback: defaultValues?[ parameter.specification.key]
            )
        }
    }

    private func defaultValue(
        for parameter: NativeAlternativePaymentInteractorState.Parameter,
        fallback: PONativeAlternativePaymentParameterValue?
    ) -> PONativeAlternativePaymentParameterValue? {
        switch parameter.specification {
        case .singleSelect(let specification):
            if case .string(let value) = fallback {
                let availableValues = Set(specification.availableValues.map(\.value))
                precondition(availableValues.contains(value), "Unsupported `singleSelect` parameter value.")
                return .string(value)
            }
            if let preselectedValue = specification.preselectedValue {
                return .string(preselectedValue.value)
            }
        case .phoneNumber(let specification):
            if case .phone(let value) = fallback {
                var regionCode: String?
                if let valueRegionCode = value.regionCode {
                    if specification.dialingCodes.contains(where: { $0.regionCode == valueRegionCode }) {
                        regionCode = valueRegionCode
                    } else {
                        assertionFailure("Unsupported region code.")
                    }
                }
                return .phone(.init(regionCode: regionCode, number: value.number))
            }
        default:
            if case .string(let value) = fallback {
                return .string(parameter.formatter?.string(for: value) ?? value)
            }
        }
        return nil
    }

    // MARK: - Local Validation

    private func validatedValues(
        for parameters: [NativeAlternativePaymentInteractorState.Parameter]
    ) throws -> [String: PONativeAlternativePaymentSubmitDataV2.Parameter] {
        var validatedValues: [String: PONativeAlternativePaymentSubmitDataV2.Parameter] = [:]
        var invalidFields: [POFailure.InvalidField] = []
        parameters.forEach { parameter in
            var invalidField: POFailure.InvalidField?
            if let validatedValue = validate(parameter: parameter, validation: &invalidField) {
                validatedValues[parameter.specification.key] = validatedValue
            } else if let invalidField {
                invalidFields.append(invalidField)
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

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    private func validate(
        parameter: NativeAlternativePaymentInteractorState.Parameter, validation: inout POFailure.InvalidField?
    ) -> PONativeAlternativePaymentSubmitDataV2.Parameter? {
        let errorMessage: String?
        switch parameter.specification {
        case .text(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength,
                maxLength: specification.maxLength,
                required: specification.required
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map(PONativeAlternativePaymentSubmitDataV2.Parameter.string)
            }
            errorMessage = validation.errorMessage
        case .singleSelect(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validation =
                NativeAlternativePaymentTextValidator(required: specification.required).validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .boolean(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validation =
                NativeAlternativePaymentTextValidator(required: specification.required).validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .digits(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength,
                maxLength: specification.maxLength,
                required: specification.required
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .phoneNumber(let specification):
            let normalizedValue = NativeAlternativePaymentPhoneNumberNormalizer().normalize(input: parameter.value)
            let validation =
                NativeAlternativePaymentPhoneNumberValidator(required: specification.required).validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .init(value: .phone($0)) }
            }
            errorMessage = validation.errorMessage
        case .email(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validation =
                NativeAlternativePaymentTextValidator(required: specification.required).validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .card(let specification):
            let normalizedValue = NativeAlternativePaymentCardNumberNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength, maxLength: specification.maxLength, required: specification.required
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .otp(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength, maxLength: specification.maxLength, required: specification.required
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .unknown:
            assertionFailure("Unable to validate unknown parameter.")
            return nil
        }
        validation = .init(
            name: parameter.specification.key,
            message: errorMessage ?? String(resource: .NativeAlternativePayment.Error.invalidValue)
        )
        return nil
    }
}

// swiftlint:enable file_length type_body_length
