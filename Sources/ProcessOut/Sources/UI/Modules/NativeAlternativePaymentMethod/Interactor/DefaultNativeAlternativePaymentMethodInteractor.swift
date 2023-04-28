//
//  DefaultNativeAlternativePaymentMethodInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.10.2022.
//

// swiftlint:disable file_length type_body_length

import Foundation
import UIKit

final class DefaultNativeAlternativePaymentMethodInteractor:
    BaseInteractor<NativeAlternativePaymentMethodInteractorState>, NativeAlternativePaymentMethodInteractor {

    init(
        invoicesService: POInvoicesService,
        imagesRepository: POImagesRepository,
        configuration: NativeAlternativePaymentMethodInteractorConfiguration,
        logger: POLogger,
        delegate: PONativeAlternativePaymentMethodDelegate?
    ) {
        self.invoicesService = invoicesService
        self.imagesRepository = imagesRepository
        self.configuration = configuration
        self.logger = logger
        self.delegate = delegate
        super.init(state: .idle)
    }

    deinit {
        captureCancellable?.cancel()
    }

    // MARK: - NativeAlternativePaymentMethodInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        logger.info("Starting payment using configuration: \(String(describing: configuration))")
        send(event: .willStart)
        state = .starting
        let request = PONativeAlternativePaymentMethodTransactionDetailsRequest(
            invoiceId: configuration.invoiceId, gatewayConfigurationId: configuration.gatewayConfigurationId
        )
        invoicesService.nativeAlternativePaymentMethodTransactionDetails(request: request) { [weak self] result in
            switch result {
            case let .success(details):
                self?.imagesRepository.image(url: details.gateway.logoUrl) { [weak self] image in
                    self?.defaultValues(for: details.parameters) { values in
                        self?.setStartedStateUnchecked(details: details, gatewayLogo: image, defaultValues: values)
                    }
                }
            case .failure(let failure):
                self?.logger.error("Failed to start payment: \(failure)")
                self?.setFailureStateUnchecked(failure: failure)
            }
        }
    }

    func formatted(value: String, type: PONativeAlternativePaymentMethodParameter.ParameterType) -> String {
        switch type {
        case .phone:
            return phoneNumberFormatter.formattedNumber(from: value)
        default:
            return value
        }
    }

    func updateValue(_ value: String?, for key: String) {
        guard case let .started(startedState) = state,
              let parameter = startedState.parameters.first(where: { $0.key == key }) else {
            return
        }
        let formattedValue = formatted(value: value ?? "", type: parameter.type)
        guard startedState.values[key]?.value != formattedValue else {
            logger.debug("Ignored the same value for key: \(key)")
            return
        }
        var updatedValues = startedState.values
        updatedValues[key] = .init(value: formattedValue, recentErrorMessage: nil)
        let updatedStartedState = startedState.replacing(
            parameters: startedState.parameters,
            values: updatedValues,
            isSubmitAllowed: isSubmitAllowed(values: updatedValues)
        )
        state = .started(updatedStartedState)
        send(event: .parametersChanged)
        logger.debug("Did update parameter value '\(value ?? "nil")' for '\(key)' key")
    }

    func submit() {
        guard case let .started(startedState) = state, startedState.isSubmitAllowed else {
            return
        }
        logger.info("Will submit '\(configuration.invoiceId)' payment parameters")
        send(event: .willSubmitParameters)
        do {
            let values = try validated(values: startedState.values, for: startedState.parameters)
            let request = PONativeAlternativePaymentMethodRequest(
                invoiceId: configuration.invoiceId,
                gatewayConfigurationId: configuration.gatewayConfigurationId,
                parameters: values
            )
            state = .submitting(snapshot: startedState)
            invoicesService.initiatePayment(request: request) { [weak self] result in
                switch result {
                case let .success(response) where response.nativeApm.state == .pendingCapture:
                    self?.send(event: .didSubmitParameters(additionalParametersExpected: false))
                    let message = startedState.customerActionMessage
                    if let imageUrl = startedState.customerActionImageUrl {
                        self?.imagesRepository.image(url: imageUrl) { image in
                            self?.trySetAwaitingCaptureStateUnchecked(
                                gatewayLogo: startedState.gatewayLogo,
                                expectedActionMessage: message,
                                actionImage: image
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
                    self?.defaultValues(for: response.nativeApm.parameterDefinitions) { values in
                        self?.restoreStartedStateAfterSubmission(nativeApm: response.nativeApm, defaultValues: values)
                    }
                case let .failure(failure):
                    self?.restoreStartedStateAfterSubmissionFailureIfPossible(failure, replaceErrorMessages: true)
                }
            }
        } catch let error as POFailure {
            restoreStartedStateAfterSubmissionFailureIfPossible(error)
        } catch {
            let failure = POFailure(code: .internal(.mobile), underlyingError: error)
            restoreStartedStateAfterSubmissionFailureIfPossible(failure)
        }
    }

    func cancel() {
        guard case .started = state else {
            logger.info("Ignored cancellation attempt from unsupported state: \(String(describing: state))")
            return
        }
        logger.debug("Will cancel payment \(configuration.invoiceId)")
        setFailureStateUnchecked(failure: POFailure(code: .cancelled))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let phoneFormattingCharacters = CharacterSet(charactersIn: "-() ")
        static let emailRegex = #"^\S+@\S+$"#
        static let phoneRegex = #"^\+?\d{1,3}\d*$"#
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let imagesRepository: POImagesRepository
    private let configuration: NativeAlternativePaymentMethodInteractorConfiguration
    private let logger: POLogger
    private weak var delegate: PONativeAlternativePaymentMethodDelegate?

    private lazy var phoneNumberFormatter: PhoneNumberFormatter = {
        PhoneNumberFormatter()
    }()

    private var captureCancellable: POCancellable?

    // MARK: - State Management

    private func setStartedStateUnchecked(
        details: PONativeAlternativePaymentMethodTransactionDetails,
        gatewayLogo: UIImage?,
        defaultValues: [String: State.ParameterValue]
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
            setCapturedStateUnchecked(gatewayLogo: gatewayLogo)
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
            values: defaultValues,
            isSubmitAllowed: isSubmitAllowed(values: defaultValues)
        )
        state = .started(startedState)
        send(event: .didStart)
        logger.info("Did start \(configuration.invoiceId) payment, waiting for parameters")
    }

    private func trySetAwaitingCaptureStateUnchecked(
        gatewayLogo: UIImage?, expectedActionMessage: String?, actionImage: UIImage?
    ) {
        guard configuration.waitsPaymentConfirmation else {
            logger.info("Won't await payment capture because waitsPaymentConfirmation is set to false")
            state = .submitted
            return
        }
        send(event: .willWaitForCaptureConfirmation(additionalActionExpected: expectedActionMessage != nil))
        let awaitingCaptureState = State.AwaitingCapture(
            gatewayLogoImage: gatewayLogo,
            expectedActionMessage: expectedActionMessage.map { _ in
                // Server doesn't support localizing action messages, so local generic message is used instead.
                Strings.NativeAlternativePayment.AwaitingCapture.message
            },
            actionImage: actionImage
        )
        state = .awaitingCapture(awaitingCaptureState)
        logger.info("Waiting for invoice \(configuration.invoiceId) capture confirmation")
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
                self?.setFailureStateUnchecked(failure: failure)
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
        setCapturedStateUnchecked(gatewayLogo: gatewayLogo)
    }

    private func setCapturedStateUnchecked(gatewayLogo: UIImage?) {
        logger.info("Did receive invoice '\(configuration.invoiceId)' capture confirmation")
        if configuration.waitsPaymentConfirmation {
            state = .captured(.init(gatewayLogo: gatewayLogo))
            send(event: .didCompletePayment)
        } else {
            logger.info("Should't wait for confirmation, so setting submitted state instead of captured.")
            state = .submitted
        }
    }

    private func restoreStartedStateAfterSubmissionFailureIfPossible(
        _ failure: POFailure, replaceErrorMessages: Bool = false
    ) {
        logger.error("Did fail to submit parameters: \(failure)")
        let startedState: State.Started
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
            setFailureStateUnchecked(failure: failure)
            return
        }
        var updatedValues: [String: State.ParameterValue] = [:]
        startedState.parameters.forEach { parameter in
            let errorMessage: String?
            if !replaceErrorMessages {
                errorMessage = invalidFields[parameter.key]?.message
            } else if invalidFields[parameter.key] != nil {
                // Server doesn't support localized error messages, so local generic error
                // description is used instead in case particular field is invalid.
                switch parameter.type {
                case .numeric:
                    errorMessage = Strings.NativeAlternativePayment.Error.invalidNumber
                case .text, .singleSelect:
                    errorMessage = Strings.NativeAlternativePayment.Error.invalidValue
                case .email:
                    errorMessage = Strings.NativeAlternativePayment.Error.invalidEmail
                case .phone:
                    errorMessage = Strings.NativeAlternativePayment.Error.invalidPhone
                }
            } else {
                errorMessage = nil
            }
            let value = startedState.values[parameter.key]?.value ?? ""
            updatedValues[parameter.key] = .init(value: value, recentErrorMessage: errorMessage)
        }
        let updatedStartedState = startedState.replacing(
            parameters: startedState.parameters, values: updatedValues, isSubmitAllowed: false
        )
        self.state = .started(updatedStartedState)
        send(event: .didFailToSubmitParameters(failure: failure))
        logger.debug("One or more parameters are not valid: \(invalidFields), waiting for parameters to update")
    }

    private func restoreStartedStateAfterSubmission(
        nativeApm: PONativeAlternativePaymentMethodResponse.NativeApm, defaultValues: [String: State.ParameterValue]
    ) {
        guard case let .submitting(startedState) = state else {
            return
        }
        let parameters = nativeApm.parameterDefinitions ?? []
        let updatedStartedState = startedState.replacing(
            parameters: parameters, values: defaultValues, isSubmitAllowed: isSubmitAllowed(values: defaultValues)
        )
        state = .started(updatedStartedState)
        send(event: .didSubmitParameters(additionalParametersExpected: true))
        logger.debug("More parameters are expected, waiting for parameters to update")
    }

    private func setFailureStateUnchecked(failure: POFailure) {
        state = .failure(failure)
        send(event: .didFail(failure: failure))
    }

    // MARK: - Utils

    private func isSubmitAllowed(values: [String: State.ParameterValue]) -> Bool {
        values.values.allSatisfy { $0.recentErrorMessage == nil }
    }

    private func send(event: PONativeAlternativePaymentMethodEvent) {
        logger.debug("Did send event: '\(String(describing: event))'")
        delegate?.nativeAlternativePaymentMethodDidEmitEvent(event)
    }

    private func defaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter]?,
        completion: @escaping ([String: State.ParameterValue]) -> Void
    ) {
        guard let parameters, !parameters.isEmpty else {
            completion([:])
            return
        }
        if let delegate {
            delegate.nativeAlternativePaymentMethodDefaultValues(for: parameters) { [self] values in
                assert(Thread.isMainThread, "Completion must be called on main thread.")
                var defaultValues: [String: State.ParameterValue] = [:]
                parameters.forEach { parameter in
                    let defaultValue: String
                    if let value = values[parameter.key] {
                        switch parameter.type {
                        case .email, .numeric, .phone, .text:
                            if let length = parameter.length {
                                precondition(value.count == length, "Unexpected parameter length.")
                            }
                            defaultValue = self.formatted(value: value, type: parameter.type)
                        case .singleSelect:
                            precondition(
                                parameter.availableValues?.map(\.displayName).contains(value) == true,
                                "Unknown choice parameter value."
                            )
                            defaultValue = value
                        }
                    } else {
                        defaultValue = self.defaultValue(for: parameter)
                    }
                    defaultValues[parameter.key] = .init(value: defaultValue, recentErrorMessage: nil)
                }
                completion(defaultValues)
            }
        } else {
            var defaultValues: [String: State.ParameterValue] = [:]
            parameters.forEach { parameter in
                defaultValues[parameter.key] = .init(value: defaultValue(for: parameter), recentErrorMessage: nil)
            }
            completion(defaultValues)
        }
    }

    private func defaultValue(for parameter: PONativeAlternativePaymentMethodParameter) -> String {
        switch parameter.type {
        case .email, .numeric, .phone, .text:
            return formatted(value: "", type: parameter.type)
        case .singleSelect:
            return parameter.availableValues?.first { $0.default == true }?.displayName ?? ""
        }
    }

    private func validated(
        values: [String: State.ParameterValue], for parameters: [PONativeAlternativePaymentMethodParameter]
    ) throws -> [String: String] {
        var validatedValues: [String: String] = [:]
        var invalidFields: [POFailure.InvalidField] = []
        parameters.forEach { parameter in
            let value = values[parameter.key]?.value
            let updatedValue: String? = {
                if case .phone = parameter.type, let value {
                    return value.removingCharacters(in: Constants.phoneFormattingCharacters)
                }
                return value
            }()
            if let updatedValue, value != updatedValue {
                logger.debug("Will use updated value '\(updatedValue)' for key '\(parameter.key)'")
            }
            if let invalidField = validate(value: updatedValue ?? "", for: parameter) {
                invalidFields.append(invalidField)
            } else {
                validatedValues[parameter.key] = updatedValue
            }
        }
        if invalidFields.isEmpty {
            return validatedValues
        }
        throw POFailure(code: .validation(.general), invalidFields: invalidFields)
    }

    private func validate(
        value: String, for parameter: PONativeAlternativePaymentMethodParameter
    ) -> POFailure.InvalidField? {
        let message: String?
        if value.isEmpty {
            if parameter.required {
                message = Strings.NativeAlternativePayment.Error.requiredParameter
            } else {
                message = nil
            }
        } else if let length = parameter.length, value.count != length {
            message = Strings.NativeAlternativePayment.Error.invalidLength(length)
        } else {
            switch parameter.type {
            case .numeric where !CharacterSet(charactersIn: value).isSubset(of: .decimalDigits):
                message = Strings.NativeAlternativePayment.Error.invalidNumber
            case .email where value.range(of: Constants.emailRegex, options: .regularExpression) == nil:
                message = Strings.NativeAlternativePayment.Error.invalidEmail
            case .phone where value.range(of: Constants.phoneRegex, options: .regularExpression) == nil:
                message = Strings.NativeAlternativePayment.Error.invalidPhone
            case .singleSelect where parameter.availableValues?.map(\.displayName).contains(value) == false:
                message = Strings.NativeAlternativePayment.Error.invalidValue
            default:
                message = nil
            }
        }
        return message.map { POFailure.InvalidField(name: parameter.key, message: $0) }
    }
}

// swiftlint:disable:next no_extension_access_modifier
private extension NativeAlternativePaymentMethodInteractorState.Started {

    func replacing(
        parameters: [PONativeAlternativePaymentMethodParameter],
        values: [String: NativeAlternativePaymentMethodInteractorState.ParameterValue],
        isSubmitAllowed: Bool
    ) -> Self {
        let updatedState = Self(
            gatewayDisplayName: gatewayDisplayName,
            gatewayLogo: gatewayLogo,
            customerActionImageUrl: customerActionImageUrl,
            customerActionMessage: customerActionMessage,
            amount: amount,
            currencyCode: currencyCode,
            parameters: parameters,
            values: values,
            isSubmitAllowed: isSubmitAllowed
        )
        return updatedState
    }
}

// swiftlint:enable file_length type_body_length
