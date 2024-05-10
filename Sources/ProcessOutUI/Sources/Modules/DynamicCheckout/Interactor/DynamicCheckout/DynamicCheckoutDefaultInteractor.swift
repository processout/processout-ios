//
//  DynamicCheckoutDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

// swiftlint:disable file_length

import Foundation
import PassKit
@_spi(PO) import ProcessOut

// swiftlint:disable:next type_body_length
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

    func select(paymentMethodId: String) -> Bool {
        let startedStateSnapshot: State.Started
        switch state {
        case .started(let startedState):
            startedStateSnapshot = startedState
        case .selected(let selectedState):
            if selectedState.paymentMethodId == paymentMethodId {
                logger.debug("Payment method is already selected, ignored", attributes: ["MethodId": paymentMethodId])
                return true
            }
            startedStateSnapshot = selectedState.snapshot
        case .paymentProcessing(let paymentProcessingState):
            startedStateSnapshot = paymentProcessingState.snapshot
            // todo(andrii-vysotskyi): actually cancel payment
            paymentProcessingState.cardTokenizationInteractor?.delegate = nil
            paymentProcessingState.nativeAlternativePaymentInteractor?.delegate = nil
        default:
            logger.debug("Unable to change selection in unsupported state: \(state)")
            return false
        }
        guard startedStateSnapshot.paymentMethods.keys.contains(paymentMethodId) else {
            preconditionFailure("Attempted to select non existing payment method.")
        }
        guard !startedStateSnapshot.unavailablePaymentMethodIds.contains(paymentMethodId) else {
            logger.debug("Payment method is unavailable, ignored", attributes: ["MethodId": paymentMethodId])
            return false
        }
        let newState = State.Selected(
            snapshot: startedStateSnapshot, paymentMethodId: paymentMethodId
        )
        state = .selected(newState)
        delegate?.dynamicCheckout(didEmitEvent: .didSelectPaymentMethod)
        return true
    }

    @discardableResult
    func startPayment(methodId: String) -> Bool {
        switch state {
        case .selected(let selectedState) where selectedState.paymentMethodId == methodId:
            let startedState = selectedState.snapshot
            guard let paymentMethod = startedState.paymentMethods[methodId] else {
                assertionFailure("Non existing payment method ID.")
                return false
            }
            switch paymentMethod {
            case .applePay:
                initiatePassKitPayment(methodId: methodId, startedState: startedState)
            case .card:
                initiateCardPayment(methodId: methodId, startedState: startedState)
            case .alternativePayment(let payment):
                initiateAlternativePayment(payment, methodId: methodId, startedState: startedState)
            case .nativeAlternativePayment(let payment):
                initiateNativeAlternativePayment(payment, methodId: methodId, startedState: startedState)
            default:
                return false
            }
            return true
        case .started, .selected, .paymentProcessing:
            if select(paymentMethodId: methodId) {
                return startPayment(methodId: methodId)
            }
        default:
            return false
        }
        return false
    }

    func submit() {
        guard case .paymentProcessing(let processingState) = state else {
            return
        }
        switch currentPaymentMethod(state: processingState) {
        case .card:
            processingState.cardTokenizationInteractor?.tokenize()
        case .nativeAlternativePayment:
            processingState.nativeAlternativePaymentInteractor?.submit()
        default:
            assertionFailure("Active payment method doesn't support forced submission")
        }
    }

    @discardableResult
    func cancel() -> Bool {
        switch state {
        case .paymentProcessing(let paymentProcessingState) where paymentProcessingState.isCancellable:
            // todo(andrii-vysotskyi): potentially cancelation could be immediate
            switch currentPaymentMethod(state: paymentProcessingState) {
            case .card:
                return paymentProcessingState.cardTokenizationInteractor?.cancel() ?? false
            case .nativeAlternativePayment:
                return paymentProcessingState.nativeAlternativePaymentInteractor?.cancel() ?? false
            default:
                assertionFailure("Currently active payment method can't be cancelled.")
                return false
            }
        case .started, .selected:
            setFailureStateUnchecked(error: POFailure(code: .cancelled))
            return true
        default:
            assertionFailure("Attempted to cancel payment from unsupported state.")
            return false
        }
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
        _ = startPayment(methodId: paymentMethod.id)
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
            request.currencyCode = invoice.currency
            request.merchantCapabilities = paymentMethod.configuration.merchantCapabilities
            // todo(andrii-vysotskyi): set supported networks
            return request
        }
        return nil
    }

    // MARK: - Pass Kit Payment

    private func initiatePassKitPayment(methodId: String, startedState: State.Started) {
        guard let request = startedState.pkPaymentRequest else {
            assertionFailure("Attempted to initiate PassKit payment without request.")
            return
        }
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
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

    private func initiateCardPayment(methodId: String, startedState: State.Started) {
        let interactor = childProvider.cardTokenizationInteractor()
        interactor.delegate = self
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            submission: .possible,
            isCancellable: false,
            cardTokenizationInteractor: interactor
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    // MARK: - Alternative Payment

    private func initiateAlternativePayment(
        _ payment: PODynamicCheckoutPaymentMethod.AlternativePayment,
        methodId: String,
        startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState, paymentMethodId: methodId, submission: .submitting, isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        Task { @MainActor in
            do {
                _ = try await alternativePaymentInteractor.start(url: payment.configuration.redirectUrl)
                setSuccessState()
            } catch {
                self.restoreStateAfterPaymentProcessingFailureIfPossible(error)
            }
        }
    }

    private func initiateNativeAlternativePayment(
        _ payment: PODynamicCheckoutPaymentMethod.NativeAlternativePayment,
        methodId: String,
        startedState: State.Started
    ) {
        let interactor = childProvider.nativeAlternativePaymentInteractor(gatewayId: payment.configuration.gatewayId)
        interactor.delegate = self
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            submission: .submitting,
            isCancellable: false,
            isReady: false,
            nativeAlternativePaymentInteractor: interactor
        )
        state = .paymentProcessing(paymentProcessingState)
        interactor.start()
    }

    // MARK: - Started State Restoration

    /// - NOTE: Only cancellation errors are restored at a time.
    private func restoreStateAfterPaymentProcessingFailureIfPossible(_ error: Error) {
        logger.info("Did fail to process payment: \(error)")
        guard case .paymentProcessing(var paymentProcessingState) = state else {
            logger.debug("Failures are expected only when processing payment, aborted")
            return
        }
        guard let failure = error as? POFailure else {
            logger.debug("Won't recover unknown failure")
            setFailureStateUnchecked(error: error)
            return
        }
        let currentPaymentMethod = self.currentPaymentMethod(state: paymentProcessingState)
        switch currentPaymentMethod {
        case .nativeAlternativePayment:
            setPaymentMethodsUnavailable(ofKinds: [.nativeAlternativePayment], state: &paymentProcessingState.snapshot)
        case .card:
            if case .generic(.cardFailed3DS) = failure.code {
                setPaymentMethodsUnavailable(ofKinds: [.card], state: &paymentProcessingState.snapshot)
            }
        default:
            break
        }
        // todo(andrii-vysotskyi): decide if user should be able to continue
        // todo(andrii-vysotskyi): comunicate error to user
        state = .started(paymentProcessingState.snapshot)
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

    // MARK: - Payment Methods Availability

    private func setPaymentMethodsUnavailable(ofKind kinds: PaymentMethodKind...) {
        guard case .paymentProcessing(var state) = state else {
            preconditionFailure("No payment method is currently being processed.")
        }
        setPaymentMethodsUnavailable(ofKinds: Set(kinds), state: &state.snapshot)
        self.state = .paymentProcessing(state)
    }

    private func setPaymentMethodsUnavailable(ofKinds kinds: Set<PaymentMethodKind>, state: inout State.Started) {
        var methodIds: Set<String> = []
        state.paymentMethods.forEach { id, paymentMethod in
            switch paymentMethod {
            case .nativeAlternativePayment where kinds.contains(.nativeAlternativePayment):
                break
            case .card where kinds.contains(.card):
                break
            case .alternativePayment where kinds.contains(.alternativePayment):
                break
            case .applePay where kinds.contains(.applePay):
                break
            default:
                return
            }
            methodIds.insert(id)
        }
        state.unavailablePaymentMethodIds.formUnion(methodIds)
    }

    // MARK: - Utils

    private func currentPaymentMethod(state: State.PaymentProcessing) -> PODynamicCheckoutPaymentMethod {
        let id = state.paymentMethodId
        guard let paymentMethod = state.snapshot.paymentMethods[id] else {
            preconditionFailure("Non existing payment method ID.")
        }
        return paymentMethod
    }
}

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

    func cardTokenization(didChangeState state: POCardTokenizationState) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state,
              case .card = currentPaymentMethod(state: paymentProcessingState) else {
            assertionFailure("No currently active card payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .started(let isSubmittable):
            paymentProcessingState.submission = isSubmittable ? .possible : .temporarilyUnavailable
            paymentProcessingState.isCancellable = paymentProcessingState.snapshot.isCancellable
            self.state = .paymentProcessing(paymentProcessingState)
        case .tokenizing:
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = false
            self.state = .paymentProcessing(paymentProcessingState)
        case .completed(result: .success):
            paymentProcessingState.cardTokenizationInteractor?.delegate = nil
            setSuccessState()
        case .completed(result: .failure(let failure)):
            paymentProcessingState.cardTokenizationInteractor?.delegate = nil
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }
}

extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEvent) {
        switch event {
        case .didSubmitParameters, .didFailToSubmitParameters:
            // todo(andrii-vysotskyi): postpone this logic til user actually selects payment method
            setPaymentMethodsUnavailable(ofKind: .nativeAlternativePayment)
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

    func nativeAlternativePayment(didChangeState state: PONativeAlternativePaymentState) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state,
              case .nativeAlternativePayment = currentPaymentMethod(state: paymentProcessingState) else {
            assertionFailure("No currently active alternative payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .starting:
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = false
            paymentProcessingState.isReady = false
            self.state = .paymentProcessing(paymentProcessingState)
        case .started(let startedState):
            paymentProcessingState.submission = startedState.isSubmittable ? .possible : .temporarilyUnavailable
            paymentProcessingState.isCancellable = startedState.isCancellable
            paymentProcessingState.isReady = true
            self.state = .paymentProcessing(paymentProcessingState)
        case .submitting(let submittingState):
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = submittingState.isCancellable
            paymentProcessingState.isReady = true
            self.state = .paymentProcessing(paymentProcessingState)
        case .completed(result: .success):
            paymentProcessingState.nativeAlternativePaymentInteractor?.delegate = nil
            setSuccessState()
        case .completed(result: .failure(let failure)):
            paymentProcessingState.nativeAlternativePaymentInteractor?.delegate = nil
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }
}

// swiftlint:enable file_length
