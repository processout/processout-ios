//
//  DynamicCheckoutDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

// swiftlint:disable file_length type_body_length

import Foundation
import PassKit
@_spi(PO) import ProcessOut

@available(iOS 14, *)
final class DynamicCheckoutDefaultInteractor:
    BaseInteractor<DynamicCheckoutInteractorState>, DynamicCheckoutInteractor {

    init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate?,
        childProvider: DynamicCheckoutInteractorChildProvider,
        invoicesService: POInvoicesService,
        cardsService: POCardsService,
        alternativePaymentsService: POAlternativePaymentsService,
        eventEmitter: POEventEmitter,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.childProvider = childProvider
        self.invoicesService = invoicesService
        self.cardsService = cardsService
        self.alternativePaymentsService = alternativePaymentsService
        self.eventEmitter = eventEmitter
        self.logger = logger
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - DynamicCheckoutInteractor

    let configuration: PODynamicCheckoutConfiguration

    override func start() {
        guard case .idle = state else {
            return
        }
        send(event: .willStart)
        let task = Task { @MainActor in
            do {
                let invoice = try await invoicesService.invoice(request: configuration.invoiceRequest)
                switch invoice.transaction?.status {
                case .waiting:
                    setStartedState(invoice: invoice, clientSecret: configuration.invoiceRequest.clientSecret)
                    if case .started = state {
                        send(event: .didStart)
                        initiateDefaultPaymentIfNeeded()
                    }
                case .authorized, .completed:
                    setSuccessState()
                default:
                    let message = "Unsupported invoice state, please create new invoice and restart checkout."
                    throw POFailure(message: message, code: .Mobile.generic)
                }
            } catch {
                setFailureState(error: error)
            }
        }
        state = .starting(.init(task: task))
        observeGlobalEvents()
    }

    func setShouldSaveSelectedPaymentMethod(_ shouldSave: Bool) {
        switch state {
        case .selected(let currentState) where currentState.shouldSavePaymentMethod != nil:
            logger.debug("Will change payment method saving selection to \(shouldSave)")
            var newState = currentState
            newState.shouldSavePaymentMethod = shouldSave
            state = .selected(newState)
        default:
            logger.error("Ignoring attempt to change payment method saving in unsupported state: \(state).")
        }
    }

    func select(methodId: String) {
        select(methodId: methodId, shouldStart: false)
    }

    func startPayment(methodId: String) {
        switch state {
        case .started:
            select(methodId: methodId, shouldStart: true)
        case .selected(let currentState):
            let shouldSave = currentState.shouldSavePaymentMethod.map { shouldSave in
                currentState.paymentMethod.id == methodId && shouldSave
            }
            continuePaymentProcessingUnchecked(
                paymentMethodId: methodId, shouldSavePaymentMethod: shouldSave, startedState: currentState.snapshot
            )
        case .paymentProcessing:
            restart(toProcess: methodId, shouldStart: true)
        case .restarting(var newState):
            newState.pendingPaymentMethodId = methodId
            newState.shouldStartPendingPaymentMethod = true
            state = .restarting(newState)
        default:
            logger.debug("Unable to start payment in unsupported state: \(state).")
        }
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .restarting(let currentState):
            currentState.task.cancel()
        case .paymentProcessing(let currentState):
            cancelCurrentPayment(in: currentState)
        case .success(let currentState):
            currentState.completionTask.cancel() // Fast-forward completion invocation.
        default:
            break // No ongoing operation to cancel
        }
        setFailureState(error: POFailure(message: "Dynamic checkout has been canceled.", code: .Mobile.cancelled))
    }

    func didRequestCancelConfirmation() {
        if case .paymentProcessing(let currentState) = state {
            currentState.nativeAlternativePaymentInteractor?.didRequestCancelConfirmation()
        }
        send(event: .didRequestCancelConfirmation)
    }

    func savedPaymentMethodsConfiguration() -> POSavedPaymentMethodsConfiguration {
        let invoiceRequest: POInvoiceRequest
        switch state {
        case .started(let currentState):
            invoiceRequest = .init(invoiceId: currentState.invoice.id, clientSecret: currentState.clientSecret)
        case .starting:
            invoiceRequest = configuration.invoiceRequest
        case .restarting(let currentState):
            invoiceRequest = .init(
                invoiceId: currentState.snapshot.snapshot.invoice.id,
                clientSecret: currentState.snapshot.snapshot.clientSecret
            )
        case .selected(let currentState):
            invoiceRequest = .init(
                invoiceId: currentState.snapshot.invoice.id, clientSecret: currentState.snapshot.clientSecret
            )
        case .paymentProcessing(let currentState):
            invoiceRequest = .init(
                invoiceId: currentState.snapshot.invoice.id, clientSecret: currentState.snapshot.clientSecret
            )
        default:
            preconditionFailure("Unable to resolve configuration in current state.")
        }
        let configuration = delegate?.dynamicCheckout(savedPaymentMethodsConfigurationWith: invoiceRequest)
        return configuration ?? .init(invoiceRequest: invoiceRequest)
    }

    // MARK: - Private Properties

    private let childProvider: DynamicCheckoutInteractorChildProvider
    private let invoicesService: POInvoicesService
    private let cardsService: POCardsService
    private let alternativePaymentsService: POAlternativePaymentsService
    private let eventEmitter: POEventEmitter
    private let completion: (Result<Void, POFailure>) -> Void

    private var logger: POLogger
    private weak var delegate: PODynamicCheckoutDelegate?

    // MARK: - Starting State

    private func setStartedState(invoice: POInvoice, clientSecret: String?, errorDescription: String? = nil) {
        switch state {
        case .starting, .restarting:
            break
        default:
            logger.debug("Unable to set started state from unsupported state: \(state).")
            return
        }
        // swiftlint:disable:next line_length
        if let paymentMethods = invoice.paymentMethods?.filter({ isSupported(paymentMethod: $0) }), !paymentMethods.isEmpty {
            let startedState = DynamicCheckoutInteractorState.Started(
                paymentMethods: paymentMethods,
                isCancellable: configuration.cancelButton?.title.map { !$0.isEmpty } ?? true,
                invoice: invoice,
                clientSecret: clientSecret,
                recentErrorDescription: errorDescription
            )
            state = .started(startedState)
            logger[attributeKey: .invoiceId] = invoice.id
            logger.debug("Did start dynamic checkout flow.")
        } else {
            let failure = POFailure(message: "Payment methods are not available.", code: .Mobile.generic)
            setFailureState(error: failure)
        }
    }

    private func initiateDefaultPaymentIfNeeded() {
        guard case .started(let startedState) = state else {
            assertionFailure("Default payment could be initiated only from started state")
            return
        }
        guard configuration.allowsSkippingPaymentList,
              startedState.paymentMethods.count == 1,
              let paymentMethod = startedState.paymentMethods.first else {
            return
        }
        switch paymentMethod {
        case .card, .nativeAlternativePayment:
            startPayment(methodId: paymentMethod.id)
        default:
            return
        }
    }

    private func isSupported(paymentMethod: PODynamicCheckoutPaymentMethod) -> Bool {
        switch paymentMethod {
        case .applePay:
            return PKPaymentAuthorizationController.canMakePayments()
        case .alternativePayment, .nativeAlternativePayment, .card, .customerToken:
            return true
        default:
            return false
        }
    }

    // MARK: - Restarting State

    private func restart(toProcess methodId: String, shouldStart: Bool) {
        guard case .paymentProcessing(let currentState) = state else {
            logger.debug("Can only restart interactor during payment processing, ignored.")
            return
        }
        guard currentState.paymentMethod.id != methodId else {
            logger.debug("Requested payment method is already being processed, ignored.")
            return
        }
        cancelCurrentPayment(in: currentState)
        let newState = State.Restarting(
            snapshot: currentState,
            task: Task { @MainActor in
                await continueRestart(reason: .paymentMethodChanged)
            },
            failure: nil,
            pendingPaymentMethodId: methodId,
            shouldStartPendingPaymentMethod: shouldStart
        )
        state = .restarting(newState)
    }

    private func restart(toRecoverPaymentProcessingError error: Error) {
        logger.info("Did fail to process payment: \(error)")
        guard !Task.isCancelled else {
            logger.debug("Associated task was cancelled, won't recover.")
            return
        }
        guard case .paymentProcessing(let currentState) = state else {
            logger.debug("Can only restart interactor during payment processing, ignored.")
            return
        }
        guard let failure = error as? POFailure else {
            setFailureState(error: error)
            return
        }
        send(event: .didFailPayment(.init(paymentMethod: currentState.paymentMethod, failure: failure)))
        if delegate?.dynamicCheckout(shouldContinueAfter: failure) != false {
            let task = Task {
                await continueRestart(reason: .failure(failure))
            }
            state = .restarting(.init(snapshot: currentState, task: task, failure: failure))
        } else {
            setFailureState(error: error)
        }
    }

    private func continueRestart(reason: PODynamicCheckoutInvoiceInvalidationReason) async {
        guard case .restarting(let currentState) = state else {
            logger.debug("Unable continue restart in unsupported state: \(state).")
            return
        }
        do {
            let shouldCreateNewInvoice = switch currentState.failure?.failureCode {
            case nil:
                currentState.snapshot.shouldInvalidateInvoice
            case .Mobile.networkUnreachable,
                 .Mobile.timeout,
                 .Mobile.cancelled,
                 .Gateway.timeout,
                 .Customer.cancelled,
                 .Authentication.invalid,
                 .Authentication.invalidProjectId:
                currentState.snapshot.shouldInvalidateInvoice
            default:
                true
            }
            if shouldCreateNewInvoice {
                guard let invoiceRequest = await delegate?.dynamicCheckout(
                    newInvoiceFor: currentState.snapshot.snapshot.invoice, invalidationReason: reason
                ) else {
                    throw POFailure(message: "Unable to restart dynamic checkout.", code: .Mobile.generic)
                }
                finishRestart(
                    with: try await invoicesService.invoice(request: invoiceRequest),
                    clientSecret: invoiceRequest.clientSecret
                )
            } else {
                finishRestartWithExistingInvoice()
            }
        } catch {
            setFailureState(error: error)
        }
    }

    private func finishRestart(with newInvoice: POInvoice, clientSecret: String?) {
        guard case .restarting(let currentState) = state else {
            logger.debug("Unexpected state to finish restart: \(state).")
            return
        }
        guard let transaction = newInvoice.transaction, transaction.status == .waiting else {
            // Another restart is not attempted to prevent potential recursion
            let failure = POFailure(message: "Unsupported invoice state.", code: .Mobile.generic)
            setFailureState(error: failure)
            return
        }
        let isPendingPaymentMethodAvailable = newInvoice.paymentMethods?
            .contains { $0.id == currentState.pendingPaymentMethodId } ?? false
        let errorDescription: String?
        if currentState.pendingPaymentMethodId != nil, !isPendingPaymentMethodAvailable {
            errorDescription = String(resource: .DynamicCheckout.Error.methodUnavailable)
        } else {
            errorDescription = failureDescription(currentState.failure)
        }
        setStartedState(invoice: newInvoice, clientSecret: clientSecret, errorDescription: errorDescription)
        if let methodId = currentState.pendingPaymentMethodId, isPendingPaymentMethodAvailable {
            // todo(andrii-vysotskyi): decide whether input should be preserved for card tokenization
            select(methodId: methodId, shouldStart: currentState.shouldStartPendingPaymentMethod)
        } else {
            logger.debug("Ignoring pending method selection because it is not available or not set.")
        }
    }

    private func finishRestartWithExistingInvoice() {
        guard case .restarting(let currentState) = state else {
            logger.debug("Unexpected state to finish restart: \(state).")
            return
        }
        let newState = DynamicCheckoutInteractorState.Started(
            paymentMethods: currentState.snapshot.snapshot.paymentMethods,
            isCancellable: currentState.snapshot.snapshot.isCancellable,
            invoice: currentState.snapshot.snapshot.invoice,
            clientSecret: currentState.snapshot.snapshot.clientSecret,
            recentErrorDescription: failureDescription(currentState.failure)
        )
        state = .started(newState)
        logger.debug("Did restart dynamic checkout flow.")
        if let methodId = currentState.pendingPaymentMethodId {
            select(methodId: methodId, shouldStart: currentState.shouldStartPendingPaymentMethod)
        } else {
            logger.debug("Ignoring pending method selection because it is not available or not set.")
        }
        // todo(andrii-vysotskyi): decide whether input should be preserved for card tokenization
    }

    private func failureDescription(_ failure: POFailure?) -> String? {
        switch failure?.failureCode {
        case .Mobile.cancelled, .Customer.cancelled, nil:
            return nil
        default:
            return String(resource: .DynamicCheckout.Error.generic)
        }
    }

    private func cancelCurrentPayment(in state: State.PaymentProcessing) {
        state.cardTokenizationInteractor?.delegate = nil
        state.cardTokenizationInteractor?.willChange = nil
        state.cardTokenizationInteractor?.cancel()
        state.nativeAlternativePaymentInteractor?.delegate = nil
        state.nativeAlternativePaymentInteractor?.willChange = nil
        state.nativeAlternativePaymentInteractor?.cancel()
        state.task?.cancel()
    }

    // MARK: - Selected State

    private func select(methodId: String, shouldStart: Bool) {
        switch state {
        case .started(let currentState):
            guard let paymentMethod = paymentMethod(withId: methodId, in: currentState) else {
                return
            }
            send(event: .willSelectPaymentMethod(paymentMethod))
            setSelectedStateUnchecked(
                paymentMethod: paymentMethod, shouldStart: shouldStart, startedState: currentState
            )
        case .selected(let currentState) where currentState.paymentMethod.id != methodId:
            guard let paymentMethod = paymentMethod(withId: methodId, in: currentState.snapshot) else {
                return
            }
            send(event: .willSelectPaymentMethod(paymentMethod))
            setSelectedStateUnchecked(
                paymentMethod: paymentMethod, shouldStart: shouldStart, startedState: currentState.snapshot
            )
        case .restarting(var currentState):
            guard let paymentMethod = paymentMethod(withId: methodId, in: currentState.snapshot.snapshot) else {
                return
            }
            send(event: .willSelectPaymentMethod(paymentMethod))
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = shouldStart
            state = .restarting(currentState)
        case .paymentProcessing(let currentState):
            guard let paymentMethod = paymentMethod(withId: methodId, in: currentState.snapshot) else {
                return
            }
            send(event: .willSelectPaymentMethod(paymentMethod))
            restart(toProcess: methodId, shouldStart: shouldStart)
        default:
            logger.debug("Unable to change selection in unsupported state: \(state).")
        }
    }

    private func setSelectedStateUnchecked(
        paymentMethod: PODynamicCheckoutPaymentMethod, shouldStart: Bool, startedState: State.Started
    ) {
        send(event: .didSelectPaymentMethod(paymentMethod))
        var newStartedState = startedState
        newStartedState.recentErrorDescription = nil
        let newState = State.Selected(
            snapshot: newStartedState,
            paymentMethod: paymentMethod,
            shouldSavePaymentMethod: canSave(paymentMethod: paymentMethod) ? false : nil
        )
        state = .selected(newState)
        if shouldStart {
            startPayment(methodId: paymentMethod.id)
        }
    }

    private func canSave(paymentMethod: PODynamicCheckoutPaymentMethod) -> Bool {
        if case .alternativePayment(let paymentMethod) = paymentMethod {
            return paymentMethod.configuration.savingAllowed
        }
        // Card saving is managed internally by corresponding payment interactor.
        return false
    }

    // MARK: - Payment Processing

    private func continuePaymentProcessingUnchecked(
        paymentMethodId: String, shouldSavePaymentMethod: Bool?, startedState: State.Started
    ) {
        guard let paymentMethod = paymentMethod(withId: paymentMethodId, in: startedState) else {
            return
        }
        var newStartedState = startedState
        newStartedState.recentErrorDescription = nil
        switch paymentMethod {
        case .applePay(let method):
            startPassKitPayment(method: method, startedState: newStartedState)
        case .card(let method):
            startCardPayment(method: method, startedState: newStartedState)
        case .alternativePayment(let method):
            startAlternativePayment(
                method: method, shouldSavePaymentMethod: shouldSavePaymentMethod, startedState: newStartedState
            )
        case .nativeAlternativePayment(let method):
            startNativeAlternativePayment(method: method, startedState: newStartedState)
        case .customerToken(let method):
            startCustomerTokenPayment(method: method, startedState: newStartedState)
        default:
            logger.error("Attempted to start unknown payment method.")
        }
    }

    // MARK: - Pass Kit Payment

    private func startPassKitPayment(method: PODynamicCheckoutPaymentMethod.ApplePay, startedState: State.Started) {
        let task = Task { @MainActor in
            do {
                guard let delegate else {
                    throw POFailure(message: "Delegate must be set to authorize invoice.", code: .Mobile.generic)
                }
                let request = pkPaymentRequest(for: method, invoice: startedState.invoice)
                await delegate.dynamicCheckout(willAuthorizeInvoiceWith: request)
                let card = try await cardsService.tokenize(
                    request: POApplePayTokenizationRequest(paymentRequest: request)
                )
                invalidateInvoiceIfPossible()
                var authorizationRequest = POInvoiceAuthorizationRequest(
                    invoiceId: startedState.invoice.id, source: card.id
                )
                let threeDSService = await delegate.dynamicCheckout(
                    willAuthorizeInvoiceWith: &authorizationRequest, using: .applePay(method)
                )
                try await invoicesService.authorizeInvoice(
                    request: authorizationRequest, threeDSService: threeDSService
                )
                setSuccessState()
            } catch {
                restart(toRecoverPaymentProcessingError: error)
            }
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethod: .applePay(method),
            willSavePaymentMethod: nil,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            task: task,
            isCancellable: false,
            shouldInvalidateInvoice: false
        )
        state = .paymentProcessing(paymentProcessingState)
    }

    private func pkPaymentRequest(
        for paymentMethod: PODynamicCheckoutPaymentMethod.ApplePay, invoice: POInvoice
    ) -> PKPaymentRequest {
        let availableNetworks = Set(PKPaymentRequest.availableNetworks())
        let request = PKPaymentRequest()
        request.merchantIdentifier = paymentMethod.configuration.merchantId
        request.countryCode = paymentMethod.configuration.countryCode
        request.merchantCapabilities = paymentMethod.configuration.merchantCapabilities
        request.supportedNetworks = paymentMethod.configuration.supportedNetworks
            .filter(availableNetworks.contains)
        request.currencyCode = invoice.currency
        return request
    }

    // MARK: - Card Payment

    private func startCardPayment(method: PODynamicCheckoutPaymentMethod.Card, startedState: State.Started) {
        let interactor = childProvider.cardTokenizationInteractor(for: method, invoiceId: startedState.invoice.id)
        interactor.delegate = self
        interactor.willChange = { [weak self] state in
            self?.cardTokenization(willChangeState: state)
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethod: .card(method),
            willSavePaymentMethod: nil,
            cardTokenizationInteractor: interactor,
            nativeAlternativePaymentInteractor: nil,
            task: nil,
            isCancellable: true
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    private func cardTokenization(willChangeState state: CardTokenizationInteractorState) {
        guard case .paymentProcessing(var currentState) = self.state,
              case .card = currentState.paymentMethod else {
            assertionFailure("No currently active card payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .started:
            currentState.isCancellable = currentState.snapshot.isCancellable
            self.state = .paymentProcessing(currentState)
        case .tokenizing, .evaluatingEligibility:
            currentState.isCancellable = false
            self.state = .paymentProcessing(currentState)
        case .tokenized:
            setSuccessState()
        case .failure(let failure):
            restart(toRecoverPaymentProcessingError: failure)
        }
    }

    // MARK: - Alternative Payment

    private func startAlternativePayment(
        method: PODynamicCheckoutPaymentMethod.AlternativePayment,
        shouldSavePaymentMethod: Bool?,
        startedState: State.Started
    ) {
        let task = Task { @MainActor in
            do {
                let source: String, saveSource = shouldSavePaymentMethod ?? false
                if saveSource {
                    source = method.configuration.gatewayConfigurationId
                } else {
                    let request = POAlternativePaymentAuthenticationRequest(
                        url: method.configuration.redirectUrl,
                        prefersEphemeralSession: false
                    )
                    source = try await alternativePaymentsService.authenticate(request: request).gatewayToken
                }
                try await authorizeInvoice(
                    using: .alternativePayment(method),
                    source: source,
                    saveSource: saveSource,
                    prefersEphemeralWebAuthenticationSession: false,
                    startedState: startedState
                )
                setSuccessState()
            } catch {
                restart(toRecoverPaymentProcessingError: error)
            }
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethod: .alternativePayment(method),
            willSavePaymentMethod: shouldSavePaymentMethod,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            task: task,
            isCancellable: false,
            shouldInvalidateInvoice: true
        )
        state = .paymentProcessing(paymentProcessingState)
    }

    // MARK: - Native Alternative Payment

    private func startNativeAlternativePayment(
        method: PODynamicCheckoutPaymentMethod.NativeAlternativePayment, startedState: State.Started
    ) {
        let configuration = delegate?.dynamicCheckout(willStartAlternativePayment: method)
            ?? configuration.alternativePayment
        let interactor = childProvider.nativeAlternativePaymentInteractor(
            for: method, invoiceId: startedState.invoice.id, configuration: configuration
        )
        // interactor.delegate = self
        interactor.willChange = { [weak self] state in
            self?.nativeAlternativePayment(willChangeState: state)
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethod: .nativeAlternativePayment(method),
            willSavePaymentMethod: nil,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: interactor,
            task: nil,
            isCancellable: true,
            isReady: false
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    private func nativeAlternativePayment(willChangeState state: NativeAlternativePaymentInteractorState) {
        guard case .paymentProcessing(var currentState) = self.state,
              case .nativeAlternativePayment = currentState.paymentMethod else {
            assertionFailure("No currently active alternative payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .starting:
            currentState.isCancellable = true
            currentState.isReady = false
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .started(let startedState):
            currentState.isCancellable = startedState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .submitting(let submittingState):
            currentState.isCancellable = submittingState.snapshot.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .awaitingRedirect(let awaitingRedirectState):
            currentState.isCancellable = awaitingRedirectState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .redirecting(let redirectingState):
            currentState.isCancellable = redirectingState.snapshot.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .awaitingCompletion(let awaitingCaptureState):
            currentState.isCancellable = awaitingCaptureState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = true
            self.state = .paymentProcessing(currentState)
        case .completed:
            setSuccessState()
        case .failure(let failure):
            restart(toRecoverPaymentProcessingError: failure)
        }
    }

    // MARK: - Token Payment

    private func startCustomerTokenPayment(
        method: PODynamicCheckoutPaymentMethod.CustomerToken, startedState: State.Started
    ) {
        let task = Task { @MainActor in
            do {
                var source = method.configuration.customerTokenId
                if let redirectUrl = method.configuration.redirectUrl {
                    let request = POAlternativePaymentAuthenticationRequest(
                        url: redirectUrl,
                        prefersEphemeralSession: method.type == .card
                    )
                    source = try await alternativePaymentsService.authenticate(request: request).gatewayToken
                }
                try await authorizeInvoice(
                    using: .customerToken(method),
                    source: source,
                    saveSource: false,
                    prefersEphemeralWebAuthenticationSession: method.type == .card,
                    startedState: startedState
                )
                setSuccessState()
            } catch {
                restart(toRecoverPaymentProcessingError: error)
            }
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethod: .customerToken(method),
            willSavePaymentMethod: nil,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            task: task,
            isCancellable: false,
            shouldInvalidateInvoice: true
        )
        state = .paymentProcessing(paymentProcessingState)
    }

    // MARK: - Failure State

    private func setFailureState(error: Error) {
        guard !Task.isCancelled else {
            logger.debug("Associated task is cancelled, ignored.")
            return
        }
        guard !state.isSink else {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(error).")
            return
        }
        logger.warn("Did fail to process dynamic checkout payment: '\(error)'.")
        let failure: POFailure
        if let error = error as? POFailure {
            failure = error
        } else {
            logger.error("Unexpected error type: \(error)")
            failure = POFailure(code: .Mobile.generic, underlyingError: error)
        }
        state = .failure(failure)
        send(event: .didFail(failure: failure))
        completion(.failure(failure))
    }

    // MARK: - Success State

    private func setSuccessState() {
        guard !state.isSink else {
            logger.debug("Already in a sink state, ignoring attempt to set success state.")
            return
        }
        let task = Task { @MainActor in
            try? await Task.sleep(seconds: configuration.paymentSuccess?.duration ?? 0)
            completion(.success(()))
        }
        state = .success(.init(completionTask: task))
        send(event: .didCompletePayment)
    }

    // MARK: - Events

    private func send(event: PODynamicCheckoutEvent) {
        logger.debug("Did send event: '\(event)'")
        delegate?.dynamicCheckout(didEmitEvent: event)
    }

    // MARK: - Global Events

    private var customerTokenDeletedSubscription: AnyObject?

    private func observeGlobalEvents() {
        customerTokenDeletedSubscription = eventEmitter.on(POCustomerTokenDeletedEvent.self) { [weak self] event in
            Task { @MainActor [weak self] in
                self?.onCustomerTokenDeleted(event: event)
            }
            return true
        }
    }

    private func onCustomerTokenDeleted(event: POCustomerTokenDeletedEvent) {
        switch state {
        case .restarting(let currentState) where currentState.snapshot.snapshot.invoice.customerId == event.customerId:
            var newStartedState = currentState.snapshot.snapshot
            newStartedState.paymentMethods.removeAll { paymentMethod in
                paymentMethod.id == event.tokenId
            }
            var newState = currentState
            newState.snapshot.snapshot = newStartedState
            if currentState.pendingPaymentMethodId == event.tokenId {
                newState.pendingPaymentMethodId = nil
                newState.shouldStartPendingPaymentMethod = false
            }
            state = .restarting(newState)
        case .started(let currentState) where currentState.invoice.customerId == event.customerId:
            var newState = currentState
            newState.paymentMethods.removeAll { paymentMethod in
                paymentMethod.id == event.tokenId
            }
            state = .started(newState)
        case .selected(let currentState) where currentState.snapshot.invoice.customerId == event.customerId:
            var newStartedState = currentState.snapshot
            newStartedState.paymentMethods.removeAll { paymentMethod in
                paymentMethod.id == event.tokenId
            }
            if currentState.paymentMethod.id == event.tokenId {
                state = .started(newStartedState)
            } else {
                var newState = currentState
                newState.snapshot = newStartedState
                state = .selected(newState)
            }
        case .paymentProcessing(let currentState) where currentState.snapshot.invoice.customerId == event.customerId:
            // Even if the currently processed payment method was deleted, the underlying operation
            // is not canceled, allowing it to complete naturally.
            var newStartedState = currentState.snapshot
            newStartedState.paymentMethods.removeAll { paymentMethod in
                paymentMethod.id == event.tokenId
            }
            var newState = currentState
            newState.snapshot = newStartedState
            state = .paymentProcessing(newState)
        default:
            break // Nothing to do
        }
    }

    // MARK: - Utils

    private func invalidateInvoiceIfPossible() {
        if case .paymentProcessing(var currentState) = state {
            currentState.shouldInvalidateInvoice = true
            state = .paymentProcessing(currentState)
        }
    }

    private func authorizeInvoice(
        using paymentMethod: PODynamicCheckoutPaymentMethod,
        source: String,
        saveSource: Bool,
        prefersEphemeralWebAuthenticationSession: Bool,
        startedState: State.Started
    ) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .Mobile.generic)
        }
        var request = POInvoiceAuthorizationRequest(
            invoiceId: startedState.invoice.id,
            source: source,
            saveSource: saveSource,
            allowFallbackToSale: true,
            clientSecret: startedState.clientSecret,
            prefersEphemeralWebAuthenticationSession: prefersEphemeralWebAuthenticationSession
        )
        let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &request, using: paymentMethod)
        try await invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService)
    }

    private func paymentMethod(withId id: String, in state: State.Started) -> PODynamicCheckoutPaymentMethod? {
        if let paymentMethod = state.paymentMethods.first(where: { $0.id == id }) {
            return paymentMethod
        }
        logger.debug("Unable to resolve payment method: \(id).")
        return nil
    }
}

@available(iOS 14, *)
extension DynamicCheckoutDefaultInteractor: POCardTokenizationDelegate {

    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        delegate?.dynamicCheckout(didEmitCardTokenizationEvent: event)
    }

    func cardTokenization(didTokenizeCard card: POCard, shouldSaveCard save: Bool) async throws {
        invalidateInvoiceIfPossible()
        guard case .paymentProcessing(let currentState) = state else {
            logger.error("Unable to process card in unsupported state: \(state).")
            throw POFailure(message: "Something went wrong.", code: .Mobile.internal)
        }
        try await authorizeInvoice(
            using: currentState.paymentMethod,
            source: card.id,
            saveSource: save,
            prefersEphemeralWebAuthenticationSession: true,
            startedState: currentState.snapshot
        )
    }

    func cardTokenization(preferredSchemeWith issuerInformation: POCardIssuerInformation) -> POCardScheme? {
        delegate?.dynamicCheckout(preferredSchemeWith: issuerInformation)
    }

    func shouldContinueTokenization(after failure: POFailure) -> Bool {
        guard case .paymentProcessing(let currentState) = state else {
            return false
        }
        return !currentState.shouldInvalidateInvoice
    }

    func cardTokenization(willScanCardWith configuration: POCardScannerConfiguration) -> POCardScannerDelegate? {
        delegate?.dynamicCheckout(willScanCardWith: configuration)
    }
}

@available(iOS 14, *)
extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegateV2 {

    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEventV2) {
        switch event {
        case .willSubmitParameters:
            invalidateInvoiceIfPossible()
        default:
            break
        }
        delegate?.dynamicCheckout(didEmitAlternativePaymentEvent: event)
    }

    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentFormV2.Parameter]
    ) async -> [String: PONativeAlternativePaymentParameterValue] {
        guard case .paymentProcessing(let currentState) = state,
              case .nativeAlternativePayment(let paymentMethod) = currentState.paymentMethod else {
            logger.error("Unable to resolve default values in current state: \(state).")
            return [:]
        }
        let request = PODynamicCheckoutAlternativePaymentDefaultsRequest(
            paymentMethod: paymentMethod, parameters: parameters
        )
        return await delegate?.dynamicCheckout(alternativePaymentDefaultsWith: request) ?? [:]
    }
}

// swiftlint:enable file_length type_body_length
