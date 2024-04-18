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

    override func start() {
        guard case .idle = state else {
            assertionFailure("Interactor start must be attempted only once.")
            return
        }
        delegate?.dynamicCheckout(didEmitEvent: .willStart)
        state = .starting
        Task {
            await continueStartUnchecked()
        }
    }

    @discardableResult
    func initiatePayment(methodId: String) -> Bool {
        switch state {
        case .started(let startedState):
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
                return false // todo(andrii-vysotskyi): handle other payment methods
            }
            delegate?.dynamicCheckout(didEmitEvent: .didSelectPaymentMethod)
            return true
        case .paymentProcessing(var paymentProcessingState) where paymentProcessingState.isCancellable && paymentProcessingState.paymentMethodId != methodId: // swiftlint:disable:this line_length
            paymentProcessingState.pendingPaymentMethodId = methodId
            state = .paymentProcessing(paymentProcessingState)
            cancel()
            return true
        default:
            return false
        }
    }

    func submit() {
        switch currentPaymentMethod {
        case .card:
            cardTokenizationInteractor?.tokenize()
        case .nativeAlternativePayment:
            nativeAlternativePaymentInteractor?.submit()
        case nil:
            assertionFailure("No payment method to submit")
        default:
            assertionFailure("Active payment method doesn't support forced submission")
        }
    }

    @discardableResult
    func cancel() -> Bool {
        switch state {
        case .paymentProcessing(let paymentProcessingState) where paymentProcessingState.isCancellable:
            guard let paymentMethod = currentPaymentMethod else {
                return false
            }
            // todo(andrii-vysotskyi): potentially cancelation could be immediate
            switch paymentMethod {
            case .card:
                return cardTokenizationInteractor?.cancel() ?? false
            case .nativeAlternativePayment:
                return nativeAlternativePaymentInteractor?.cancel() ?? false
            default:
                assertionFailure("Currently active payment method can't be cancelled.")
                return false
            }
        case .started:
            setFailureStateUnchecked(error: POFailure(code: .cancelled))
            return true
        default:
            assertionFailure("Attempted to cancel payment from unsupported state.")
            return false
        }
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutConfiguration
    private let passKitPaymentInteractor: DynamicCheckoutPassKitPaymentInteractor
    private let alternativePaymentInteractor: DynamicCheckoutAlternativePaymentInteractor
    private let childProvider: DynamicCheckoutInteractorChildProvider
    private let invoicesService: POInvoicesService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    private var cardTokenizationInteractor: (any CardTokenizationInteractor)?
    private var nativeAlternativePaymentInteractor: (any NativeAlternativePaymentInteractor)?

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
        let pkPaymentRequest = await pkPaymentRequest(
            paymentMethods: invoice.paymentMethods ?? []
        )
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
            break // todo(andrii-vysotskyi): only allow native APMs
        default:
            return
        }
        _ = initiatePayment(methodId: paymentMethod.id)
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
            case .applePay(let method) where passKitPaymentInteractor.isSupported && !ignorePassKit:
                if method.flow == .express {
                    expressIds.append(paymentMethod.id)
                } else {
                    regularIds.append(paymentMethod.id)
                }
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

    private func pkPaymentRequest(paymentMethods: [PODynamicCheckoutPaymentMethod]) async -> PKPaymentRequest? {
        guard passKitPaymentInteractor.isSupported else {
            logger.debug("PassKit is not supported, won't attempt to resolve request.")
            return nil
        }
        let paymentMethod = paymentMethods .first { paymentMethod in
            if case .applePay = paymentMethod {
                return true
            }
            return false
        }
        guard case .applePay(let applePayPaymentMethod) = paymentMethod else {
            return nil
        }
        return await delegate?.dynamicCheckout(passKitPaymentRequestWith: applePayPaymentMethod.configuration)
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
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            submission: .unavailable,
            isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        let interactor = childProvider.cardTokenizationInteractor(delegate: self)
        interactor.start()
        cardTokenizationInteractor = interactor
    }

    // MARK: - Alternative Payment

    private func initiateAlternativePayment(
        _ payment: PODynamicCheckoutPaymentMethod.AlternativePayment,
        methodId: String,
        startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            submission: .submitting,
            isCancellable: false
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
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState,
            paymentMethodId: methodId,
            submission: .unavailable,
            isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        let interactor = childProvider.nativeAlternativePaymentInteractor(
            gatewayId: payment.configuration.gatewayId, delegate: self
        )
        interactor.start()
        self.nativeAlternativePaymentInteractor = interactor
    }

    // MARK: - Started State Restoration

    /// - NOTE: Only cancellation errors are restored at a time.
    private func restoreStateAfterPaymentProcessingFailureIfPossible(_ error: Error) {
        // todo(andrii-vysotskyi): ask delegate whether error should be restored
        logger.info("Did fail to process payment: \(error)")
        guard case .paymentProcessing(let paymentProcessingState) = state else {
            logger.debug("Failures are expected only when processing payment, aborted")
            return
        }
        guard let failure = error as? POFailure else {
            logger.debug("Won't recover unknown failure")
            setFailureStateUnchecked(error: error)
            return
        }
        switch failure.code {
        case .cancelled:
            if let pendingPaymentMethodId = paymentProcessingState.pendingPaymentMethodId {
                state = .started(paymentProcessingState.snapshot)
                initiatePayment(methodId: pendingPaymentMethodId)
                return
            }
            guard let paymentMethod = currentPaymentMethod else {
                setFailureStateUnchecked(error: error)
                return
            }
            // todo(andrii-vysotskyi): propagate error to user after recovery
            switch paymentMethod {
            case .applePay:
                state = .started(paymentProcessingState.snapshot)
            case .alternativePayment:
                state = .started(paymentProcessingState.snapshot)
            default:
                setFailureStateUnchecked(error: error)
            }
        default:
            setFailureStateUnchecked(error: error)
        }
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
        completion(.success(()))
    }

    // MARK: - Events

    private func send(event: PODynamicCheckoutEvent) {
        assert(Thread.isMainThread, "Method should be called on main thread.")
        logger.debug("Did send event: '\(event)'")
        delegate?.dynamicCheckout(didEmitEvent: event)
    }

    // MARK: - Utils

    private var currentPaymentMethod: PODynamicCheckoutPaymentMethod? {
        guard case .paymentProcessing(let paymentProcessingState) = state else {
            logger.debug("Attempted to resolve payment method in unsupported state.")
            return nil
        }
        let id = paymentProcessingState.paymentMethodId
        guard let paymentMethod = paymentProcessingState.snapshot.paymentMethods[id] else {
            assertionFailure("Non existing payment method ID.")
            return nil
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
        delegate?.dynamicCheckout(shouldContinueAfter: failure) ?? true
    }

    func cardTokenization(didChangeState state: POCardTokenizationState) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state, case .card = currentPaymentMethod else {
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
            cardTokenizationInteractor = nil
            setSuccessState()
        case .completed(result: .failure(let failure)):
            cardTokenizationInteractor = nil
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }
}

extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePayment(didEmitEvent event: PONativeAlternativePaymentEvent) {
        delegate?.dynamicCheckout(didEmitAlternativePaymentEvent: event)
    }

    func nativeAlternativePayment(
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        await delegate?.dynamicCheckout(alternativePaymentDefaultsFor: parameters) ?? [:]
    }

    func nativeAlternativePayment(didChangeState state: PONativeAlternativePaymentState) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state,
              case .nativeAlternativePayment = currentPaymentMethod else {
            assertionFailure("No currently active alternative payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .starting:
            paymentProcessingState.submission = .unavailable
            paymentProcessingState.isCancellable = false
            self.state = .paymentProcessing(paymentProcessingState)
        case .started(let startedState):
            paymentProcessingState.submission = startedState.isSubmittable ? .possible : .temporarilyUnavailable
            paymentProcessingState.isCancellable = startedState.isCancellable
            self.state = .paymentProcessing(paymentProcessingState)
        case .submitting(let submittingState):
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = submittingState.isCancellable
            self.state = .paymentProcessing(paymentProcessingState)
        case .completed(result: .success):
            nativeAlternativePaymentInteractor = nil
            setSuccessState()
        case .completed(result: .failure(let failure)):
            nativeAlternativePaymentInteractor = nil
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
        }
    }
}

extension DynamicCheckoutDefaultInteractor: DynamicCheckoutRouterDelegate {

    func router(
        _ router: any Router<DynamicCheckoutRoute>,
        willRouteToNativeAlternativePaymentWith gatewayConfigurationId: String
    ) -> any NativeAlternativePaymentInteractor {
        guard let interactor = nativeAlternativePaymentInteractor else {
            preconditionFailure("Unable to resolve native APM interactor.")
        }
        assert(interactor.configuration.gatewayConfigurationId == gatewayConfigurationId)
        return interactor
    }

    func routerWillRouteToCardTokenization(
        _ router: any Router<DynamicCheckoutRoute>
    ) -> any CardTokenizationInteractor {
        guard let interactor = cardTokenizationInteractor else {
            preconditionFailure("Unable to resolve card tokenization interactor.")
        }
        return interactor
    }
}

// swiftlint:enable file_length
