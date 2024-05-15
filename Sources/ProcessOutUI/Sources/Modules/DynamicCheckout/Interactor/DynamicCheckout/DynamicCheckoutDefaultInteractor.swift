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
        passKitPaymentInteractor: DynamicCheckoutPassKitPaymentInteractor,
        alternativePaymentInteractor: DynamicCheckoutAlternativePaymentInteractor,
        childProvider: DynamicCheckoutInteractorChildProvider,
        invoicesService: POInvoicesService,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.passKitPaymentInteractor = passKitPaymentInteractor
        self.alternativePaymentInteractor = alternativePaymentInteractor
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
        delegate?.dynamicCheckout(didEmitEvent: .willStart)
        state = .starting
        Task {
            await continueStartUnchecked()
        }
    }

    func select(methodId: String) {
        switch state {
        case .started(let currentState):
            setSelectedStateUnchecked(methodId: methodId, startedState: currentState)
        case .selected(let currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            setSelectedStateUnchecked(methodId: methodId, startedState: currentState.snapshot)
        case .paymentProcessing(var currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            guard !currentState.snapshot.unavailablePaymentMethodIds.contains(methodId) else {
                logger.debug("Ignoring unavailable method selection", attributes: ["MethodId": methodId])
                return
            }
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = false
            state = .paymentProcessing(currentState)
            cancel(force: false)
        default:
            logger.debug("Unable to change selection in unsupported state: \(state)")
        }
    }

    func startPayment(methodId: String) {
        switch state {
        case .started(let currentState):
            setPaymentProcessingUnchecked(methodId: methodId, startedState: currentState)
        case .selected(let currentState):
            setPaymentProcessingUnchecked(methodId: methodId, startedState: currentState.snapshot)
        case .paymentProcessing(var currentState):
            guard currentState.paymentMethodId != methodId else {
                return
            }
            guard !currentState.snapshot.unavailablePaymentMethodIds.contains(methodId) else {
                logger.debug("Ignoring unavailable method selection", attributes: ["MethodId": methodId])
                return
            }
            currentState.pendingPaymentMethodId = methodId
            currentState.shouldStartPendingPaymentMethod = true
            state = .paymentProcessing(currentState)
            cancel(force: false)
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

    // MARK: - Private Nested Types

    private enum PaymentMethodKind: Hashable {
        case nativeAlternativePayment, alternativePayment, card, applePay
    }

    // MARK: - Private Properties

    private let passKitPaymentInteractor: DynamicCheckoutPassKitPaymentInteractor
    private let alternativePaymentInteractor: DynamicCheckoutAlternativePaymentInteractor
    private let childProvider: DynamicCheckoutInteractorChildProvider
    private let invoicesService: POInvoicesService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    private weak var delegate: PODynamicCheckoutDelegate?

    // MARK: - Starting State

    @MainActor
    private func continueStartUnchecked() async {
        let invoice: POInvoice
        do {
            let request = POInvoiceRequest(id: configuration.invoiceId)
            invoice = try await invoicesService.invoice(request: request)
        } catch {
            setFailureStateUnchecked(error: error)
            return
        }
        // todo(andrii-vysotskyi): decide if multiple Apple Pay payment methods should be supported.
        let pkPaymentRequest = await pkPaymentRequest(invoice: invoice)
        var expressMethodIds: [String] = [], regularMethodIds: [String] = []
        let paymentMethods = partitioned(
            paymentMethods: invoice.paymentMethods ?? [],
            expressIds: &expressMethodIds,
            regularIds: &regularMethodIds,
            ignorePassKit: pkPaymentRequest == nil
        )
        let startedState = DynamicCheckoutInteractorState.Started(
            paymentMethods: paymentMethods,
            expressPaymentMethodIds: expressMethodIds,
            regularPaymentMethodIds: regularMethodIds,
            pkPaymentRequest: pkPaymentRequest,
            isCancellable: configuration.cancelActionTitle.map { !$0.isEmpty } ?? true
        )
        state = .started(startedState)
        delegate?.dynamicCheckout(didEmitEvent: .didStart)
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
            break
        default:
            return
        }
        startPayment(methodId: paymentMethod.id)
    }

    private func partitioned(
        paymentMethods: [PODynamicCheckoutPaymentMethod],
        expressIds: inout [String],
        regularIds: inout [String],
        ignorePassKit: Bool
    ) -> [String: PODynamicCheckoutPaymentMethod] {
        // swiftlint:disable:next identifier_name
        var _paymentMethods: [String: PODynamicCheckoutPaymentMethod] = [:]
        for paymentMethod in paymentMethods {
            switch paymentMethod {
            case .applePay where !ignorePassKit:
                expressIds.append(paymentMethod.id)
            case .alternativePayment(let method):
                if method.flow == .express {
                    expressIds.append(paymentMethod.id)
                } else {
                    regularIds.append(paymentMethod.id)
                }
            case .nativeAlternativePayment:
                regularIds.append(paymentMethod.id)
            case .card:
                regularIds.append(paymentMethod.id)
            case .unknown(let rawType):
                logger.debug("Unknown payment method is ignored: \(rawType)")
                continue
            default:
                continue
            }
            _paymentMethods[paymentMethod.id] = paymentMethod
        }
        return _paymentMethods
    }

    @MainActor
    private func pkPaymentRequest(invoice: POInvoice) async -> PKPaymentRequest? {
        guard passKitPaymentInteractor.isSupported else {
            logger.debug("PassKit is not supported, won't attempt to resolve request.")
            return nil
        }
        for paymentMethod in invoice.paymentMethods ?? [] {
            guard case .applePay(let paymentMethod) = paymentMethod else {
                continue
            }
            let request = PKPaymentRequest()
            request.merchantIdentifier = paymentMethod.configuration.merchantId
            request.countryCode = paymentMethod.configuration.countryCode
            request.merchantCapabilities = paymentMethod.configuration.merchantCapabilities
            request.supportedNetworks = paymentMethod.configuration.supportedNetworks.compactMap { network in
                PKPaymentNetwork(poScheme: network)
            }
            request.currencyCode = invoice.currency
            return request
        }
        return nil
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
        default:
            assertionFailure("Attempted to cancel payment from unsupported state.")
        }
    }

    // MARK: - Selected State

    private func setSelectedStateUnchecked(methodId: String, startedState: State.Started) {
        _ = paymentMethod(withId: methodId, state: startedState)
        if startedState.pendingUnavailablePaymentMethodIds.contains(methodId) {
            var newState = startedState
            newState.unavailablePaymentMethodIds.formUnion(newState.pendingUnavailablePaymentMethodIds)
            newState.pendingUnavailablePaymentMethodIds.removeAll()
            state = .started(newState) // todo(andrii-vysotskyi): inform user why selection didn't occur
        } else if !startedState.unavailablePaymentMethodIds.contains(methodId) {
            let newState = State.Selected(snapshot: startedState, paymentMethodId: methodId)
            state = .selected(newState)
            delegate?.dynamicCheckout(didEmitEvent: .didSelectPaymentMethod)
        } else {
            logger.debug("Ignoring attempt to select unavailable payment method")
        }
    }

    // MARK: - Payment Processing

    private func setPaymentProcessingUnchecked(methodId: String, startedState: State.Started) {
        _ = paymentMethod(withId: methodId, state: startedState)
        if startedState.pendingUnavailablePaymentMethodIds.contains(methodId) {
            var newState = startedState
            newState.unavailablePaymentMethodIds.formUnion(newState.pendingUnavailablePaymentMethodIds)
            newState.pendingUnavailablePaymentMethodIds.removeAll()
            state = .started(newState) // todo(andrii-vysotskyi): inform user why selection didn't occur
        } else if !startedState.unavailablePaymentMethodIds.contains(methodId) {
            switch paymentMethod(withId: methodId, state: startedState) {
            case .applePay:
                startPassKitPayment(methodId: methodId, startedState: startedState)
            case .card(let method):
                startCardPayment(methodId: methodId, configuration: method.configuration, startedState: startedState)
            case .alternativePayment(let method):
                startAlternativePayment(
                    methodId: methodId, configuration: method.configuration, startedState: startedState
                )
            case .nativeAlternativePayment(let method):
                startNativeAlternativePayment(
                    methodId: methodId, configuration: method.configuration, startedState: startedState
                )
            default:
                preconditionFailure("Attempted to start unknown payment method")
            }
        } else {
            logger.debug("Ignoring attempt to select unavailable payment method")
        }
    }

    // MARK: - Pass Kit Payment

    private func startPassKitPayment(methodId: String, startedState: State.Started) {
        guard let request = startedState.pkPaymentRequest else {
            assertionFailure("Attempted to initiate PassKit payment without request.")
            return
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            submission: .submitting,
            isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        Task { @MainActor in
            do {
                try await passKitPaymentInteractor.start(request: request)
                setSuccessState()
            } catch {
                restoreStateAfterPaymentProcessingFailureIfPossible(error)
            }
        }
    }

    // MARK: - Card Payment

    private func startCardPayment(
        methodId: String,
        configuration: PODynamicCheckoutPaymentMethod.CardConfiguration,
        startedState: State.Started
    ) {
        let interactor = childProvider.cardTokenizationInteractor(configuration: configuration)
        interactor.delegate = self
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            cardTokenizationInteractor: interactor,
            nativeAlternativePaymentInteractor: nil,
            submission: .possible,
            isCancellable: true
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    // MARK: - Alternative Payment

    private func startAlternativePayment(
        methodId: String,
        configuration: PODynamicCheckoutPaymentMethod.AlternativePaymentConfiguration,
        startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: nil,
            submission: .submitting,
            isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        Task { @MainActor in
            do {
                _ = try await alternativePaymentInteractor.start(url: configuration.redirectUrl)
                setSuccessState()
            } catch {
                self.restoreStateAfterPaymentProcessingFailureIfPossible(error)
            }
        }
    }

    private func startNativeAlternativePayment(
        methodId: String,
        configuration: PODynamicCheckoutPaymentMethod.NativeAlternativePaymentConfiguration,
        startedState: State.Started
    ) {
        let interactor = childProvider.nativeAlternativePaymentInteractor(gatewayId: configuration.gatewayId)
        interactor.delegate = self
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            cardTokenizationInteractor: nil,
            nativeAlternativePaymentInteractor: interactor,
            submission: .submitting,
            isCancellable: false,
            isReady: false
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    // MARK: - Started State Restoration

    private func restoreStateAfterPaymentProcessingFailureIfPossible(_ error: Error) {
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
        if let methodId = currentState.pendingPaymentMethodId {
            restoreStartedStateUnchecked(failure: failure, processingState: currentState)
            if currentState.shouldStartPendingPaymentMethod {
                startPayment(methodId: methodId)
            } else {
                select(methodId: methodId)
            }
        } else if case .cancelled = failure.code, currentState.isForcelyCancelled {
            setFailureStateUnchecked(error: error)
        } else {
            restoreStartedStateUnchecked(failure: failure, processingState: currentState)
        }
    }

    private func restoreStartedStateUnchecked(failure: POFailure, processingState: State.PaymentProcessing) {
        guard delegate?.dynamicCheckout(shouldContinueAfter: failure) != false else {
            setFailureStateUnchecked(error: failure)
            return
        }
        var startedState = processingState.snapshot
        startedState.pendingUnavailablePaymentMethodIds.formUnion(processingState.pendingUnavailablePaymentMethodIds)
        if failure.code != .cancelled {
            var unavailableIds: Set<String>
            switch currentPaymentMethod(state: processingState) {
            case .nativeAlternativePayment:
                unavailableIds = paymentMethodIds(of: .nativeAlternativePayment, state: processingState.snapshot)
            case .card where .generic(.cardFailed3DS) == failure.code:
                unavailableIds = paymentMethodIds(of: .card, state: processingState.snapshot)
            default:
                unavailableIds = []
            }
            startedState.pendingUnavailablePaymentMethodIds.subtract(unavailableIds)
            startedState.unavailablePaymentMethodIds.formUnion(unavailableIds)
        }
        self.state = .started(startedState)
        // todo(andrii-vysotskyi): comunicate error to user
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
        completion(.failure(failure))
        logger.error("Did fail to process dynamic checkout payment: '\(error)'")
    }

    // MARK: - Success State

    private func setSuccessState() {
        guard case .paymentProcessing = state else {
            assertionFailure("Success state can be set only after payment processing start.")
            return
        }
        state = .success
        send(event: .didCompletePayment)
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: NSEC_PER_SEC * UInt64(configuration.success.duration))
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

    private func paymentMethodIds(of kind: PaymentMethodKind, state: State.Started) -> Set<String> {
        var methodIds: Set<String> = []
        state.paymentMethods.forEach { id, paymentMethod in
            switch paymentMethod {
            case .applePay where kind == .applePay:
                break
            case .alternativePayment where kind == .alternativePayment:
                break
            case .nativeAlternativePayment where kind == .nativeAlternativePayment:
                break
            case .card where kind == .card:
                break
            default:
                return
            }
            methodIds.insert(id)
        }
        return methodIds
    }

    private func paymentMethod(withId methodId: String, state: State.Started) -> PODynamicCheckoutPaymentMethod {
        guard let paymentMethod = state.paymentMethods[methodId] else {
            preconditionFailure("Unknown payment method ID.")
        }
        return paymentMethod
    }
}

@available(iOS 14.0, *)
extension DynamicCheckoutDefaultInteractor: POCardTokenizationDelegate {

    func cardTokenization(didEmitEvent event: POCardTokenizationEvent) {
        delegate?.dynamicCheckout(didEmitCardTokenizationEvent: event)
    }

    func cardTokenization(didTokenizeCard card: POCard) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
        }
        var request = POInvoiceAuthorizationRequest(invoiceId: configuration.invoiceId, source: card.id)
        let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &request)
        try await invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService)
    }

    func cardTokenization(preferredSchemeFor issuerInformation: POCardIssuerInformation) -> String? {
        delegate?.dynamicCheckout(preferredSchemeFor: issuerInformation)
    }

    func cardTokenization(shouldContinueAfter failure: POFailure) -> Bool {
         true // All recoverable errors should be recovered
    }

    func cardTokenization(willChangeState state: POCardTokenizationState) {
        guard case .paymentProcessing(var currentState) = self.state,
              case .card = currentPaymentMethod(state: currentState) else {
            assertionFailure("No currently active card payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .started(let isSubmittable):
            currentState.submission = isSubmittable ? .possible : .temporarilyUnavailable
            currentState.isCancellable = currentState.snapshot.isCancellable
            self.state = .paymentProcessing(currentState)
        case .tokenizing:
            currentState.submission = .submitting
            currentState.isCancellable = false
            self.state = .paymentProcessing(currentState)
        case .completed(result: .success):
            setSuccessState()
        case .completed(result: .failure(let failure)):
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }
}

@available(iOS 14.0, *)
extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEvent) {
        switch event {
        case .didSubmitParameters, .didFailToSubmitParameters:
            updateUnavailablePaymentMethods()
        default:
            return
        }
        delegate?.dynamicCheckout(didEmitAlternativePaymentEvent: event)
    }

    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        await delegate?.dynamicCheckout(alternativePaymentDefaultsFor: parameters) ?? [:]
    }

    func nativeAlternativePayment(willChangeState state: PONativeAlternativePaymentState) {
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
            self.state = .paymentProcessing(currentState)
        case .started(let startedState):
            currentState.submission = startedState.isSubmittable ? .possible : .temporarilyUnavailable
            currentState.isCancellable = startedState.isCancellable
            currentState.isReady = true
            self.state = .paymentProcessing(currentState)
        case .submitting(let submittingState):
            currentState.submission = .submitting
            currentState.isCancellable = submittingState.isCancellable
            currentState.isReady = true
            self.state = .paymentProcessing(currentState)
        case .completed(result: .success):
            setSuccessState()
        case .completed(result: .failure(let failure)):
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }

    // MARK: - Private Methods

    private func updateUnavailablePaymentMethods() {
        guard case .paymentProcessing(var currentState) = state else {
            return
        }
        var unavailableIds = paymentMethodIds(of: .nativeAlternativePayment, state: currentState.snapshot)
        unavailableIds.remove(currentState.paymentMethodId)
        currentState.pendingUnavailablePaymentMethodIds.formUnion(unavailableIds)
        state = .paymentProcessing(currentState)
    }
}

// swiftlint:enable file_length type_body_length
