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

@available(iOS 14.0, *)
final class DynamicCheckoutDefaultInteractor:
    BaseInteractor<DynamicCheckoutInteractorState>, DynamicCheckoutInteractor {

    init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate?,
        passKitPaymentSession: DynamicCheckoutPassKitPaymentSession,
        alternativePaymentSession: DynamicCheckoutAlternativePaymentSession,
        childProvider: DynamicCheckoutInteractorChildProvider,
        invoicesService: POInvoicesService,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.passKitPaymentSession = passKitPaymentSession
        self.alternativePaymentSession = alternativePaymentSession
        self.childProvider = childProvider
        self.invoicesService = invoicesService
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
        state = .starting
        Task {
            await continueStartUnchecked()
        }
    }

    func select(methodId: String) {
        switch state {
        case .started(let currentState):
            send(event: .willSelectPaymentMethod)
            setSelectedStateUnchecked(methodId: methodId, startedState: currentState)
        case .selected(let currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            send(event: .willSelectPaymentMethod)
            setSelectedStateUnchecked(methodId: methodId, startedState: currentState.snapshot)
        case .paymentProcessing(var currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = false
            state = .paymentProcessing(currentState)
            cancel(force: false)
        case .recovering(var currentState):
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = false
            state = .recovering(currentState)
        default:
            logger.debug("Unable to change selection in unsupported state: \(state)")
        }
    }

    func startPayment(methodId: String) {
        switch state {
        case .started(let currentState):
            send(event: .willSelectPaymentMethod)
            setPaymentProcessingUnchecked(methodId: methodId, startedState: currentState)
        case .selected(let currentState):
            setPaymentProcessingUnchecked(methodId: methodId, startedState: currentState.snapshot)
        case .paymentProcessing(var currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = true
            state = .paymentProcessing(currentState)
            cancel(force: false)
        case .recovering(var currentState):
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = true
            state = .recovering(currentState)
        default:
            logger.debug("Unable to start payment in unsupported state: \(state)")
        }
    }

    func submit() {
        guard case .paymentProcessing(let currentState) = state else {
            return
        }
        switch currentPaymentMethod(state: currentState) {
        case .card:
            currentState.cardTokenizationInteractor?.tokenize()
        case .nativeAlternativePayment:
            currentState.nativeAlternativePaymentInteractor?.submit()
        default:
            assertionFailure("Active payment method doesn't support forced submission")
        }
    }

    override func cancel() {
        cancel(force: true)
    }

    func didRequestCancelConfirmation() {
        guard case .paymentProcessing(let currentState) = state else {
            return
        }
        // Only nAPM interactor should be notified for now.
        currentState.nativeAlternativePaymentInteractor?.didRequestCancelConfirmation()
    }

    // MARK: - Private Nested Types

    private enum PaymentMethodKind: Hashable {
        case nativeAlternativePayment, alternativePayment, card, applePay
    }

    // MARK: - Private Properties

    private let passKitPaymentSession: DynamicCheckoutPassKitPaymentSession
    private let alternativePaymentSession: DynamicCheckoutAlternativePaymentSession
    private let childProvider: DynamicCheckoutInteractorChildProvider
    private let invoicesService: POInvoicesService
    private let completion: (Result<Void, POFailure>) -> Void

    private var logger: POLogger
    private weak var delegate: PODynamicCheckoutDelegate?

    // MARK: - Starting State

    private func continueStartUnchecked() async {
        do {
            let invoice = try await invoicesService.invoice(request: configuration.invoiceRequest)
            setStartedStateUnchecked(invoice: invoice)
        } catch {
            setFailureStateUnchecked(error: error)
        }
    }

    private func setStartedStateUnchecked(invoice: POInvoice, errorDescription: String? = nil) {
        let pkPaymentRequests = pkPaymentRequests(invoice: invoice)
        var expressMethodIds: [String] = [], regularMethodIds: [String] = []
        let paymentMethods = partitioned(
            paymentMethods: invoice.paymentMethods ?? [],
            expressIds: &expressMethodIds,
            regularIds: &regularMethodIds,
            includedApplePayPaymentMethodIds: Set(pkPaymentRequests.keys)
        )
        let startedState = DynamicCheckoutInteractorState.Started(
            paymentMethods: paymentMethods,
            expressPaymentMethodIds: expressMethodIds,
            regularPaymentMethodIds: regularMethodIds,
            pkPaymentRequests: pkPaymentRequests,
            isCancellable: configuration.cancelButton?.title.map { !$0.isEmpty } ?? true,
            invoice: invoice,
            recentErrorDescription: errorDescription
        )
        state = .started(startedState)
        send(event: .didStart)
        logger[attributeKey: .invoiceId] = invoice.id
        logger.debug("Did start dynamic checkout flow")
        initiateDefaultPaymentIfNeeded()
    }

    private func initiateDefaultPaymentIfNeeded() {
        guard case .started(let startedState) = state else {
            assertionFailure("Default payment could be initiated only from started state")
            return
        }
        guard configuration.allowsSkippingPaymentList,
              startedState.paymentMethods.count == 1,
              let paymentMethod = startedState.paymentMethods.values.first else {
            return
        }
        switch paymentMethod {
        case .card, .nativeAlternativePayment:
            startPayment(methodId: paymentMethod.id)
        default:
            return
        }
    }

    private func partitioned(
        paymentMethods: [PODynamicCheckoutPaymentMethod],
        expressIds: inout [String],
        regularIds: inout [String],
        includedApplePayPaymentMethodIds: Set<String>
    ) -> [String: PODynamicCheckoutPaymentMethod] {
        // swiftlint:disable:next identifier_name
        var _paymentMethods: [String: PODynamicCheckoutPaymentMethod] = [:]
        for paymentMethod in paymentMethods {
            // swiftlint:disable:next line_length
            guard let isExpress = isExpress(paymentMethod: paymentMethod, includedApplePayPaymentMethodIds: includedApplePayPaymentMethodIds) else {
                continue
            }
            if isExpress {
                expressIds.append(paymentMethod.id)
            } else {
                regularIds.append(paymentMethod.id)
            }
            _paymentMethods[paymentMethod.id] = paymentMethod
        }
        return _paymentMethods
    }

    private func isExpress(
        paymentMethod: PODynamicCheckoutPaymentMethod,
        includedApplePayPaymentMethodIds: Set<String>
    ) -> Bool? {
        switch paymentMethod {
        case .applePay:
            if includedApplePayPaymentMethodIds.contains(paymentMethod.id) {
                return true
            }
            return nil
        case .alternativePayment(let method):
            return method.flow == .express
        case .nativeAlternativePayment, .card:
            return false
        case .customerToken(let method):
            return method.flow == .express
        case .unknown(let rawType):
            logger.debug("Unknown payment method is ignored: \(rawType)")
            return nil
        }
    }

    private func pkPaymentRequests(invoice: POInvoice) -> [String: PKPaymentRequest] {
        guard passKitPaymentSession.isSupported else {
            logger.debug("PassKit is not supported, won't attempt to resolve request.")
            return [:]
        }
        let availableNetworks = Set(PKPaymentRequest.availableNetworks())
        var requests: [String: PKPaymentRequest] = [:]
        invoice.paymentMethods?.forEach { method in
            guard case .applePay(let method) = method else {
                return
            }
            let request = PKPaymentRequest()
            request.merchantIdentifier = method.configuration.merchantId
            request.countryCode = method.configuration.countryCode
            request.merchantCapabilities = method.configuration.merchantCapabilities
            request.supportedNetworks = method.configuration.supportedNetworks
                .compactMap(PKPaymentNetwork.init(poScheme:))
                .filter(availableNetworks.contains)
            request.currencyCode = invoice.currency
            requests[method.id] = request
        }
        return requests
    }

    // MARK: - Cancel

    /// - Parameter force: When set to `true` implementation won't attempt to restore started state.
    private func cancel(force: Bool) {
        switch state {
        case .paymentProcessing(var currentState):
            if force {
                currentState.isForcelyCancelled = true
                state = .paymentProcessing(currentState)
            }
            let interactor: (any Interactor)?
            switch currentPaymentMethod(state: currentState) {
            case .card:
                interactor = currentState.cardTokenizationInteractor
            case .nativeAlternativePayment:
                interactor = currentState.nativeAlternativePaymentInteractor
            default:
                interactor = nil
            }
            guard let interactor, currentState.isCancellable else {
                logger.debug("Current payment method is not cancellable.")
                return
            }
            interactor.cancel()
        case .started, .selected:
            setFailureStateUnchecked(error: POFailure(code: .cancelled))
        case .recovering:
            logger.debug("Ignoring attempt to cancel payment during error recovery.")
        default:
            assertionFailure("Attempted to cancel payment from unsupported state.")
        }
    }

    // MARK: - Selected State

    private func setSelectedStateUnchecked(methodId: String, startedState: State.Started) {
        _ = paymentMethod(withId: methodId, state: startedState)
        var newStartedState = startedState
        newStartedState.recentErrorDescription = nil
        let newState = State.Selected(snapshot: newStartedState, paymentMethodId: methodId)
        state = .selected(newState)
    }

    // MARK: - Payment Processing

    private func setPaymentProcessingUnchecked(methodId: String, startedState: State.Started) {
        var newStartedState = startedState
        newStartedState.recentErrorDescription = nil
        switch paymentMethod(withId: methodId, state: startedState) {
        case .applePay:
            startPassKitPayment(methodId: methodId, startedState: newStartedState)
        case .card(let method):
            startCardPayment(method: method, startedState: newStartedState)
        case .alternativePayment(let method):
            startAlternativePayment(method: method, startedState: newStartedState)
        case .nativeAlternativePayment(let method):
            startNativeAlternativePayment(method: method, startedState: newStartedState)
        case .customerToken(let method):
            startCustomerTokenPayment(method: method, startedState: newStartedState)
        case .unknown:
            preconditionFailure("Attempted to start unknown payment method")
        }
    }

    // MARK: - Pass Kit Payment

    private func startPassKitPayment(methodId: String, startedState: State.Started) {
        guard let request = startedState.pkPaymentRequests[methodId] else {
            assertionFailure("Attempted to initiate PassKit payment without request.")
            return
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            submission: .submitting,
            isCancellable: false,
            shouldInvalidateInvoice: true
        )
        state = .paymentProcessing(paymentProcessingState)
        Task {
            do {
                try await passKitPaymentSession.start(invoiceId: startedState.invoice.id, request: request)
                setSuccessState()
            } catch {
                recoverPaymentProcessing(error: error)
            }
        }
    }

    // MARK: - Card Payment

    private func startCardPayment(method: PODynamicCheckoutPaymentMethod.Card, startedState: State.Started) {
        let interactor = childProvider.cardTokenizationInteractor(
            invoiceId: startedState.invoice.id, configuration: method.configuration
        )
        interactor.delegate = self
        interactor.willChange = { [weak self] state in
            self?.cardTokenization(willChangeState: state)
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: method.id,
            cardTokenizationInteractor: interactor,
            nativeAlternativePaymentInteractor: nil,
            submission: .possible,
            isCancellable: true
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    private func cardTokenization(willChangeState state: CardTokenizationInteractorState) {
        guard case .paymentProcessing(var currentState) = self.state,
              case .card = currentPaymentMethod(state: currentState) else {
            assertionFailure("No currently active card payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .started(let startedState):
            currentState.submission = startedState.areParametersValid ? .possible : .temporarilyUnavailable
            currentState.isCancellable = currentState.snapshot.isCancellable
            self.state = .paymentProcessing(currentState)
        case .tokenizing:
            currentState.submission = .submitting
            currentState.isCancellable = false
            self.state = .paymentProcessing(currentState)
        case .tokenized:
            setSuccessState()
        case .failure(let failure):
            recoverPaymentProcessing(error: failure)
        }
    }

    private func canRecoverCardTokenization(from failure: POFailure) -> Bool {
        if case .generic(let code) = failure.code {
            let unrecoverableCodes: Set<POFailure.GenericCode> = [.cardFailed3DS, .cardPending3DS]
            return !unrecoverableCodes.contains(code)
        }
        return true
    }

    // MARK: - Alternative Payment

    private func startAlternativePayment(
        method: PODynamicCheckoutPaymentMethod.AlternativePayment, startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: method.id,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            submission: .submitting,
            isCancellable: false,
            shouldInvalidateInvoice: true
        )
        state = .paymentProcessing(paymentProcessingState)
        Task {
            do {
                _ = try await alternativePaymentSession.start(url: method.configuration.redirectUrl)
                setSuccessState()
            } catch {
                recoverPaymentProcessing(error: error)
            }
        }
    }

    // MARK: - Native Alternative Payment

    private func startNativeAlternativePayment(
        method: PODynamicCheckoutPaymentMethod.NativeAlternativePayment, startedState: State.Started
    ) {
        let interactor = childProvider.nativeAlternativePaymentInteractor(
            invoiceId: startedState.invoice.id,
            gatewayConfigurationId: method.configuration.gatewayConfigurationId
        )
        interactor.delegate = self
        interactor.willChange = { [weak self] state in
            self?.nativeAlternativePayment(willChangeState: state)
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: method.id,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: interactor,
            submission: .submitting,
            isCancellable: false,
            isReady: false
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    private func nativeAlternativePayment(willChangeState state: NativeAlternativePaymentInteractorState) {
        guard case .paymentProcessing(var currentState) = self.state,
              case .nativeAlternativePayment = currentPaymentMethod(state: currentState) else {
            assertionFailure("No currently active alternative payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .starting:
            currentState.submission = .submitting
            currentState.isCancellable = false
            currentState.isReady = false
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .started(let startedState):
            currentState.submission = startedState.areParametersValid ? .possible : .temporarilyUnavailable
            currentState.isCancellable = startedState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .submitting(let submittingState):
            currentState.submission = .submitting
            currentState.isCancellable = submittingState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = false
            self.state = .paymentProcessing(currentState)
        case .awaitingCapture(let awaitingCaptureState):
            currentState.submission = .submitting
            currentState.isCancellable = awaitingCaptureState.isCancellable
            currentState.isReady = true
            currentState.isAwaitingNativeAlternativePaymentCapture = true
            self.state = .paymentProcessing(currentState)
        case .submitted, .captured:
            setSuccessState()
        case .failure(let failure):
            recoverPaymentProcessing(error: failure)
        }
    }

    // MARK: - Token Payment

    private func startCustomerTokenPayment(
        method: PODynamicCheckoutPaymentMethod.CustomerToken, startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: method.id,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            submission: .submitting,
            isCancellable: false,
            shouldInvalidateInvoice: true
        )
        state = .paymentProcessing(paymentProcessingState)
        Task { @MainActor in
            do {
                if let redirectUrl = method.configuration.redirectUrl {
                    _ = try await alternativePaymentSession.start(url: redirectUrl)
                } else {
                    try await authorizeInvoice(source: method.configuration.customerTokenId, startedState: startedState)
                }
                setSuccessState()
            } catch {
                recoverPaymentProcessing(error: error)
            }
        }
    }

    // MARK: - Failure Recovery

    private func recoverPaymentProcessing(error: Error) {
        logger.info("Did fail to process payment: \(error)")
        guard case .paymentProcessing(let currentState) = state else {
            logger.debug("Failures are expected only when processing payment, aborted")
            return
        }
        guard let failure = error as? POFailure else {
            logger.debug("Won't recover unknown failure")
            setFailureStateUnchecked(error: error)
            return
        }
        if shouldRecover(after: failure, in: currentState) {
            Task {
                await continuePaymentProcessingRecovery(after: failure)
            }
        } else {
            setFailureStateUnchecked(error: failure)
        }
    }

    private func shouldRecover(after failure: POFailure, in state: State.PaymentProcessing) -> Bool {
        if case .cancelled = failure.code {
            return !state.isForcelyCancelled
        }
        guard let delegate else {
            return true // Errors are recovered by default
        }
        return delegate.dynamicCheckout(shouldContinueAfter: failure)
    }

    @MainActor
    private func continuePaymentProcessingRecovery(after failure: POFailure) async {
        guard case .paymentProcessing(let currentState) = state else {
            assertionFailure("Error could be recovered only when processing payment.")
            return
        }
        let recoveringState = State.Recovering(
            failure: failure,
            snapshot: currentState.snapshot,
            failedPaymentMethodId: currentState.paymentMethodId,
            pendingPaymentMethodId: currentState.pendingPaymentMethodId,
            shouldStartPendingPaymentMethod: currentState.shouldStartPendingPaymentMethod
        )
        state = .recovering(recoveringState)
        if shouldCreateNewInvoice(toRecoverFrom: failure, in: currentState) {
            do {
                guard let request = await delegate?.dynamicCheckout(newInvoiceFor: currentState.snapshot.invoice) else {
                    throw failure
                }
                let newInvoice = try await invoicesService.invoice(request: request)
                finishPaymentFailureRecovery(with: newInvoice)
            } catch {
                setFailureStateUnchecked(error: error)
            }
        } else {
            finishPaymentFailureRecovery(with: currentState.snapshot.invoice)
        }
    }

    private func finishPaymentFailureRecovery(with newInvoice: POInvoice) {
        guard case .recovering(let currentState) = state else {
            assertionFailure("Unexpected state")
            return
        }
        setStartedStateUnchecked(
            invoice: newInvoice, errorDescription: failureDescription(currentState.failure)
        )
        guard let pendingPaymentMethodId = currentState.pendingPaymentMethodId else {
            return
        }
        if currentState.shouldStartPendingPaymentMethod {
            startPayment(methodId: pendingPaymentMethodId)
        } else {
            select(methodId: pendingPaymentMethodId)
        }
        // todo(andrii-vysotskyi): decide whether input should be preserved for card tokenization
    }

    private func shouldCreateNewInvoice(
        toRecoverFrom failure: POFailure, in state: State.PaymentProcessing
    ) -> Bool {
        if state.shouldInvalidateInvoice {
            return true
        }
        // todo(andrii-vysotskyi): decide whether errors list is correct
        switch failure.code {
        case .internal, .validation, .notFound, .generic, .unknown:
            return true
        default:
            return false
        }
    }

    private func failureDescription(_ failure: POFailure) -> String? {
        if case .cancelled = failure.code {
            return nil
        }
        return String(resource: .DynamicCheckout.Error.generic)
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
        logger.warn("Did fail to process dynamic checkout payment: '\(error)'")
        state = .failure(failure)
        send(event: .didFail(failure: failure))
        completion(.failure(failure))
    }

    // MARK: - Success State

    private func setSuccessState() {
        guard case .paymentProcessing = state else {
            assertionFailure("Success state can be set only after payment processing start.")
            return
        }
        state = .success
        send(event: .didCompletePayment)
        Task {
            try? await Task.sleep(seconds: configuration.paymentSuccess?.duration ?? 0)
            completion(.success(()))
        }
    }

    // MARK: - Events

    private func send(event: PODynamicCheckoutEvent) {
        assert(Thread.isMainThread, "Method should be called on main thread.")
        logger.debug("Did send event: '\(event)'")
        delegate?.dynamicCheckout(didEmitEvent: event)
    }

    // MARK: - Utils

    private func currentPaymentMethod(state: State.PaymentProcessing) -> PODynamicCheckoutPaymentMethod {
        let id = state.paymentMethodId
        guard let paymentMethod = state.snapshot.paymentMethods[id] else {
            preconditionFailure("Non existing payment method ID.")
        }
        return paymentMethod
    }

    private func paymentMethod(withId methodId: String, state: State.Started) -> PODynamicCheckoutPaymentMethod {
        guard let paymentMethod = state.paymentMethods[methodId] else {
            preconditionFailure("Unknown payment method ID.")
        }
        return paymentMethod
    }

    private func invalidateInvoiceIfPossible() {
        if case .paymentProcessing(var currentState) = state {
            currentState.shouldInvalidateInvoice = true
            state = .paymentProcessing(currentState)
        }
    }

    @MainActor
    private func authorizeInvoice(source: String, startedState: State.Started) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
        }
        var request = POInvoiceAuthorizationRequest(
            invoiceId: startedState.invoice.id, source: source
        )
        let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &request)
        try await invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService)
    }
}

@available(iOS 14.0, *)
extension DynamicCheckoutDefaultInteractor: POCardTokenizationDelegate {

    func cardTokenizationDidEmitEvent(_ event: POCardTokenizationEvent) {
        delegate?.dynamicCheckout(didEmitCardTokenizationEvent: event)
    }

    @MainActor
    func processTokenizedCard(card: POCard) async throws {
        invalidateInvoiceIfPossible()
        guard case .paymentProcessing(let currentState) = state else {
            assertionFailure("Unable to process card in unsupported state.")
            throw POFailure(code: .internal(.mobile))
        }
        try await authorizeInvoice(source: card.id, startedState: currentState.snapshot)
    }

    func preferredScheme(issuerInformation: POCardIssuerInformation) -> String? {
        delegate?.dynamicCheckout(preferredSchemeFor: issuerInformation)
    }

    func shouldContinueTokenization(after failure: POFailure) -> Bool {
        canRecoverCardTokenization(from: failure)
    }
}

@available(iOS 14.0, *)
extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePaymentMethodDidEmitEvent(_ event: PONativeAlternativePaymentMethodEvent) {
        switch event {
        case .didSubmitParameters:
            invalidateInvoiceIfPossible()
        default:
            break
        }
        delegate?.dynamicCheckout(didEmitAlternativePaymentEvent: event)
    }

    func nativeAlternativePaymentMethodDefaultValues(
        for parameters: [PONativeAlternativePaymentMethodParameter],
        completion: @escaping @Sendable ([String: String]) -> Void
    ) {
        Task { @MainActor in
            let values = await delegate?.dynamicCheckout(alternativePaymentDefaultsFor: parameters) ?? [:]
            completion(values)
        }
    }
}

// swiftlint:enable file_length type_body_length
