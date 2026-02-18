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
        alternativePaymentsService: POAlternativePaymentsService,
        imagesRepository: POImagesRepository,
        barcodeImageProvider: BarcodeImageProvider,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.serviceAdapter = serviceAdapter
        self.alternativePaymentsService = alternativePaymentsService
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
        Task {
            await start()
        }
    }

    func start() async {
        guard case .idle = state else {
            return
        }
        logger.info("Starting native alternative payment.")
        send(event: .willStart)
        let task = Task { @MainActor in
            do {
                let request = NativeAlternativePaymentServiceAdapterRequest(
                    flow: configuration.flow, localeIdentifier: configuration.localization.localeOverride?.identifier
                )
                let payment = try await serviceAdapter.continuePayment(with: request)
                try await setState(with: payment)
            } catch {
                setFailureState(error: error)
            }
        }
        state = .starting(.init(task: task))
        _ = await task.result
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
        let task = Task { @MainActor in
            do {
                let values = try validatedValues(for: Array(currentState.parameters.values))
                let request = NativeAlternativePaymentServiceAdapterRequest(
                    flow: configuration.flow,
                    submitData: .init(parameters: values),
                    localeIdentifier: configuration.localization.localeOverride?.identifier
                )
                let payment = try await serviceAdapter.continuePayment(with: request)
                let submittedParametersSpecifications = Array(currentState.parameters.values.map(\.specification))
                switch payment.state {
                case .nextStepRequired:
                    send(
                        event: .didSubmitParameters(
                            .init(parameters: submittedParametersSpecifications, additionalParametersExpected: true)
                        )
                    )
                    logger.debug("More parameters are expected, waiting for parameters to update.")
                case .success, .pending:
                    send(
                        event: .didSubmitParameters(
                            .init(parameters: submittedParametersSpecifications, additionalParametersExpected: false)
                        )
                    )
                default:
                    setFailureState(error: POFailure(message: "Unexpected payment state.", code: .Mobile.generic))
                }
                try await setState(with: payment)
            } catch {
                attemptRecoverSubmissionError(error)
            }
        }
        state = .submitting(.init(snapshot: currentState, task: task))
    }

    func confirmPayment() {
        confirmPayment(force: false)
    }

    func confirmRedirect() {
        guard case .awaitingRedirect(let currentState) = state else {
            logger.debug("Ignoring redirect confirmation in unsupported state \(state).")
            return
        }
        let task = Task {
            do {
                let didOpenUrl: Bool
                switch currentState.redirect.type {
                case .deepLink:
                    didOpenUrl = await openDeepLink(url: currentState.redirect.url)
                case .web:
                    let authenticationRequest = POAlternativePaymentAuthenticationRequest(
                        url: currentState.redirect.url,
                        callback: configuration.redirect.callback,
                        prefersEphemeralSession: configuration.redirect.prefersEphemeralSession
                    )
                    _ = try await alternativePaymentsService.authenticate(request: authenticationRequest)
                    didOpenUrl = true
                default:
                    throw POFailure(errorDescription: "Unknown redirect type.", code: .Mobile.internal)
                }
                let response = try await serviceAdapter.continuePayment(
                    with: .init(
                        flow: configuration.flow,
                        redirect: currentState.redirect.confirmationRequired ? .init(success: didOpenUrl) : nil,
                        localeIdentifier: configuration.localization.localeOverride?.identifier
                    )
                )
                try await setState(with: response)
            } catch {
                setFailureState(error: error)
            }
        }
        let newState = State.Redirecting(task: task, snapshot: currentState)
        state = .redirecting(newState)
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .submitting(let currentState):
            currentState.task.cancel()
        case .awaitingCompletion(let currentState):
            currentState.task?.cancel()
        case .redirecting(let currentState):
            currentState.task.cancel()
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
    private let alternativePaymentsService: POAlternativePaymentsService
    private let imagesRepository: POImagesRepository
    private let barcodeImageProvider: BarcodeImageProvider
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - State Handling

    private func setState(with response: NativeAlternativePaymentServiceAdapterResponse) async throws {
        switch response.state {
        case .nextStepRequired:
            if case .starting = state, let redirect = response.redirect, configuration.redirect.enableHeadlessMode {
                try await continueStart(withHeadlessRedirect: redirect)
            } else if let redirect = response.redirect {
                try await setAwaitingRedirectState(response: response, redirect: redirect)
            } else {
                try await setStartedState(response: response)
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

    private func continueStart(withHeadlessRedirect redirect: PONativeAlternativePaymentRedirectV2) async throws {
        guard case .starting = state else {
            logger.error("Attempted to handle headless redirect while not in starting state. Ignoring.")
            return
        }
        let didOpenUrl: Bool
        switch redirect.type {
        case .deepLink:
            didOpenUrl = await openDeepLink(url: redirect.url)
        case .web:
            let authenticationRequest = POAlternativePaymentAuthenticationRequest(
                url: redirect.url,
                callback: configuration.redirect.callback,
                prefersEphemeralSession: configuration.redirect.prefersEphemeralSession
            )
            _ = try await alternativePaymentsService.authenticate(request: authenticationRequest)
            didOpenUrl = true
        default:
            throw POFailure(errorDescription: "Unknown redirect type.", code: .Mobile.internal)
        }
        let response = try await serviceAdapter.continuePayment(
            with: .init(
                flow: configuration.flow,
                redirect: redirect.confirmationRequired ? .init(success: didOpenUrl) : nil,
                localeIdentifier: configuration.localization.localeOverride?.identifier
            )
        )
        try await setState(with: response)
    }

    // MARK: - Started State

    private func setStartedState(response: NativeAlternativePaymentServiceAdapterResponse) async throws {
        let elements = try await resolve(elements: response.elements ?? [])
        let paymentMethod = await resolve(paymentMethod: response.paymentMethod)
        let parameters = await createParameters(for: response.elements ?? [])
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
            invoice: response.invoice,
            elements: elements,
            parameters: parameters,
            isCancellable: configuration.cancelButton?.disabledFor.isZero ?? true
        )
        state = .started(startedState)
        sendDidStartEventIfNeeded()
        logger.info("Did start payment, waiting for parameters.")
        enableCancellationAfterDelay()
    }

    private func enableCancellationAfterDelay() {
        guard let disabledFor = configuration.cancelButton?.disabledFor, disabledFor > 0 else {
            logger.debug("Cancel action is not set or initially enabled.")
            return
        }
        guard cancelationEnablingTask == nil else {
            logger.debug("Cancel enabling is already scheduled.")
            return
        }
        let task = Task { @MainActor in
            try? await Task.sleep(seconds: disabledFor)
            switch state {
            case .started(var currentState):
                currentState.isCancellable = true
                state = .started(currentState)
            case .submitting(let currentState):
                var updatedSnapshot = currentState.snapshot
                updatedSnapshot.isCancellable = true
                state = .submitting(.init(snapshot: updatedSnapshot, task: currentState.task))
            case .awaitingRedirect(var currentState):
                currentState.isCancellable = true
                state = .awaitingRedirect(currentState)
            case .redirecting(let currentState):
                var updatedSnapshot = currentState.snapshot
                updatedSnapshot.isCancellable = true
                state = .redirecting(.init(task: currentState.task, snapshot: updatedSnapshot))
            default:
                break
            }
        }
        self.cancelationEnablingTask = task
    }

    private var cancelationEnablingTask: Task<Void, Never>?

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
            sendDidStartEventIfNeeded()
            send(event: .willWaitForPaymentConfirmation(.init()))
            let shouldConfirmPayment =
                !resolvedElements.isEmpty && configuration.paymentConfirmation.confirmButton != nil
            let awaitingPaymentCompletionState = State.AwaitingCompletion(
                paymentMethod: await resolve(paymentMethod: response.paymentMethod),
                invoice: response.invoice,
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
                let request = NativeAlternativePaymentServiceAdapterRequest(
                    flow: configuration.flow, localeIdentifier: configuration.localization.localeOverride?.identifier
                )
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

    // MARK: - Redirect

    private func setAwaitingRedirectState(
        response: NativeAlternativePaymentServiceAdapterResponse,
        redirect: PONativeAlternativePaymentRedirectV2
    ) async throws {
        let paymentMethod = await resolve(paymentMethod: response.paymentMethod)
        let elements = try await resolve(elements: response.elements ?? [])
        switch state {
        case .starting, .submitting, .redirecting:
            break // todo(andrii-vysotskyi): check if more states should be supported
        default:
            logger.debug("Ignoring attempt to set started state in unsupported state: \(state).")
            return
        }
        let newState = State.AwaitingRedirect(
            paymentMethod: paymentMethod,
            invoice: response.invoice,
            elements: elements,
            redirect: redirect,
            isCancellable: configuration.cancelButton?.disabledFor.isZero ?? true
        )
        sendDidStartEventIfNeeded()
        state = .awaitingRedirect(newState)
        enableCancellationAfterDelay()
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
                    let shouldConfirm = !resolvedElements.isEmpty
                    try? await Task.sleep(
                        seconds: shouldConfirm ? success.extendedDisplayDuration : success.displayDuration
                    )
                    completion(.success(()))
                }
            }
            let newState = State.Completed(
                paymentMethod: await resolve(paymentMethod: response.paymentMethod),
                invoice: response.invoice,
                elements: resolvedElements,
                completionTask: task
            )
            state = .completed(newState)
            send(event: .didCompletePayment)
            if configuration.success == nil {
                completion(.success(()))
            }
        } catch {
            setFailureState(error: error)
        }
    }

    // MARK: - Submission Recovery

    private func attemptRecoverSubmissionError(_ error: Error) {
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
            let errorMessage = invalidFields[parameter.specification.key]?.message
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
        let failureEvent = PONativeAlternativePaymentEventV2.DidFail(
            failure: failure, paymentState: currentPaymentState
        )
        send(event: .didFail(failureEvent))
        completion(.failure(failure))
    }

    /// Payment state resolve from current interactor's state.
    private var currentPaymentState: PONativeAlternativePaymentStateV2? {
        switch state {
        case .idle, .starting, .failure:
            return nil
        case .started, .submitting, .awaitingRedirect, .redirecting:
            return .nextStepRequired
        case .awaitingCompletion:
            return .pending
        case .completed:
            return .success
        }
    }

    // MARK: - Cancellation Availability

    // swiftlint:disable:next identifier_name
    private var paymentConfirmationCancellationEnablingTask: Task<Void, Never>?

    private func enablePaymentConfirmationCancellationAfterDelay() {
        guard let disabledFor = configuration.paymentConfirmation.cancelButton?.disabledFor, disabledFor > 0 else {
            logger.debug("Confirmation cancel action is not set or initially enabled.")
            return
        }
        guard paymentConfirmationCancellationEnablingTask == nil else {
            logger.debug("Cancel enabling is already scheduled.")
            return
        }
        let task = Task { @MainActor in
            try? await Task.sleep(seconds: disabledFor)
            guard case .awaitingCompletion(var newState) = state else {
                return
            }
            newState.isCancellable = true
            state = .awaitingCompletion(newState)
        }
        self.paymentConfirmationCancellationEnablingTask = task
    }

    // MARK: - Events

    private func sendDidStartEventIfNeeded() {
        guard !didEmitStartEvent else {
            return
        }
        didEmitStartEvent = true
        send(event: .didStart)
    }

    private var didEmitStartEvent = false

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

    private func send(event: PONativeAlternativePaymentEventV2) {
        delegate?.nativeAlternativePayment(didEmitEvent: event)
    }

    // MARK: - Utils

    private func createParameters(
        for elements: [PONativeAlternativePaymentElementV2]
    ) async -> [String: NativeAlternativePaymentInteractorState.Parameter] {
        let parameters = elements.flatMap { element -> [State.Parameter] in
            guard case let .form(form) = element else {
                return []
            }
            let parameters = form.parameters.parameterDefinitions.map { specification -> State.Parameter in
                switch specification {
                case .card:
                    let formatter = POCardNumberFormatter()
                    return .init(specification: specification, formatter: formatter)
                case .phoneNumber(let specification):
                    let locale = configuration.localization.localeOverride ?? .current
                    let dialingCodes = specification.dialingCodes.sorted { lhs, rhs in
                        lhs.regionDisplayName(locale: locale) ?? "" < rhs.regionDisplayName(locale: locale) ?? ""
                    }
                    let updatedSpecification = PONativeAlternativePaymentFormV2.Parameter.PhoneNumber(
                        key: specification.key,
                        label: specification.label,
                        required: specification.required,
                        dialingCodes: dialingCodes
                    )
                    return .init(specification: .phoneNumber(updatedSpecification), formatter: nil)
                default:
                    return .init(specification: specification, formatter: nil)
                }
            }
            return parameters
        }
        var groupedParameters = Dictionary(grouping: parameters, by: \.specification.key).compactMapValues(\.first)
        await setDefaultValues(parameters: &groupedParameters)
        return groupedParameters
    }

    // MARK: - Customer Instructions

    private func resolve(
        group: PONativeAlternativePaymentInstructionsGroupV2
    ) async throws -> NativeAlternativePaymentResolvedElement.Group {
        var resolvedInstructions: [NativeAlternativePaymentResolvedElement.Instruction] = []
        for instruction in group.instructions {
            if let resolvedInstruction = try await resolve(customerInstruction: instruction) {
                resolvedInstructions.append(resolvedInstruction)
            }
        }
        return .init(label: group.label, instructions: resolvedInstructions)
    }

    private func resolve(
        customerInstruction: PONativeAlternativePaymentCustomerInstructionV2
    ) async throws -> NativeAlternativePaymentResolvedElement.Instruction? {
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
            guard let image = await imagesRepository.image(resource: image.value) else { // Treated as decoration
                logger.debug("Unable to prepare customer instruction image.")
                return nil
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
            if let resolvedInstruction = try await resolve(customerInstruction: instruction) {
                return .instruction(resolvedInstruction)
            }
        case .group(let group):
            return .group(try await resolve(group: group))
        case .unknown:
            return nil
        }
        return nil
    }

    // MARK: - Payment Method Utils

    private func resolve(
        paymentMethod: PONativeAlternativePaymentMethodV2
    ) async -> NativeAlternativePaymentResolvedPaymentMethod {
        let logo = await imagesRepository.image(resource: paymentMethod.logo)
        return .init(logo: logo, displayName: paymentMethod.displayName)
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
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map(PONativeAlternativePaymentSubmitDataV2.Parameter.string)
            }
            errorMessage = validation.errorMessage
        case .singleSelect(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .boolean(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .digits(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength,
                maxLength: specification.maxLength,
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .phoneNumber(let specification):
            let normalizer = NativeAlternativePaymentPhoneNumberNormalizer(
                dialingCodes: specification.dialingCodes
            )
            let normalizedValue = normalizer.normalize(input: parameter.value)
            let validator = NativeAlternativePaymentPhoneNumberValidator(
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .init(value: .phone($0)) }
            }
            errorMessage = validation.errorMessage
        case .email(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .card(let specification):
            let normalizedValue = NativeAlternativePaymentCardNumberNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength,
                maxLength: specification.maxLength,
                required: specification.required,
                localization: configuration.localization
            )
            let validation = validator.validate(normalizedValue)
            if case .valid = validation {
                return normalizedValue.map { .string($0) }
            }
            errorMessage = validation.errorMessage
        case .otp(let specification):
            let normalizedValue = NativeAlternativePaymentTextNormalizer().normalize(input: parameter.value)
            let validator = NativeAlternativePaymentTextValidator(
                minLength: specification.minLength,
                maxLength: specification.maxLength,
                required: specification.required,
                localization: configuration.localization
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
            message: errorMessage ?? String(
                resource: .NativeAlternativePayment.Error.invalidValue, configuration: configuration.localization
            )
        )
        return nil
    }

    // MARK: - Redirect Utils

    private func openDeepLink(url: URL) async -> Bool {
        let options: [UIApplication.OpenExternalURLOptionsKey: Any]
        if url.scheme == "https" || url.scheme == "http" { // Determines whether link could be universal
            options = [.universalLinksOnly: true]
        } else {
            options = [:]
        }
        return await UIApplication.shared.open(url, options: options)
    }
}

// swiftlint:enable file_length type_body_length
