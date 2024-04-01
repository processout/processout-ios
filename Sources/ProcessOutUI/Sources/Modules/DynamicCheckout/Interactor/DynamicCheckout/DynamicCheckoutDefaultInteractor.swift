//
//  DynamicCheckoutDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

// swiftlint:disable file_length

import Foundation
@_spi(PO) import ProcessOut

// swiftlint:disable:next type_body_length
final class DynamicCheckoutDefaultInteractor:
    BaseInteractor<DynamicCheckoutInteractorState>, DynamicCheckoutInteractor {

    init(
        configuration: PODynamicCheckoutConfiguration,
        delegate: PODynamicCheckoutDelegate?,
        passKitPaymentInteractor: DynamicCheckoutPassKitPaymentInteractor,
        alternativePaymentInteractor: DynamicCheckoutAlternativePaymentInteractor,
        invoicesService: POInvoicesService,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.delegate = delegate
        self.passKitPaymentInteractor = passKitPaymentInteractor
        self.alternativePaymentInteractor = alternativePaymentInteractor
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
                initiateAlternativePayment(methodId: methodId, payment: payment, startedState: startedState)
            default:
                return false // todo(andrii-vysotskyi): handle other payment methods
            }
            delegate?.dynamicCheckout(didEmitEvent: .didSelectPaymentMethod)
            return true
        case .paymentProcessing(var paymentProcessingState) where paymentProcessingState.isCancellable:
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
            cardTokenizationCoordinator?.tokenize()
        case .alternativePayment:
            // todo(andrii-vysotskyi): validate whether payment is native
            nativeAlternativePaymentCoordinator?.submit()
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
            switch paymentMethod {
            case .card:
                return cardTokenizationCoordinator?.cancel() ?? false
            case .alternativePayment:
                return nativeAlternativePaymentCoordinator?.cancel() ?? false
            default:
                logger.info("Currently active payment method can't be cancelled.")
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
    private let invoicesService: POInvoicesService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    private weak var cardTokenizationCoordinator: POCardTokenizationCoordinator?
    private weak var nativeAlternativePaymentCoordinator: PONativeAlternativePaymentCoordinator?

    private weak var delegate: PODynamicCheckoutDelegate?

    // MARK: - Starting State

    @MainActor
    private func continueStartUnchecked() async {
        let request = PODynamicCheckoutPaymentDetailsRequest(
            invoiceId: configuration.invoiceId
        )
        let paymentDetails: PODynamicCheckoutPaymentDetails
        do {
            paymentDetails = try await invoicesService.dynamicCheckoutPaymentDetails(request: request)
        } catch {
            setFailureStateUnchecked(error: error)
            return
        }
        var expressMethodIds: [String] = [], regularMethodIds: [String] = []
        let paymentMethods = partitioned(
            paymentMethods: paymentDetails.paymentMethods, expressIds: &expressMethodIds, regularIds: &regularMethodIds
        )
        let startedState = DynamicCheckoutInteractorState.Started(
            paymentMethods: paymentMethods,
            expressPaymentMethodIds: expressMethodIds,
            regularPaymentMethodIds: regularMethodIds,
            isCancellable: configuration.cancelActionTitle.map { !$0.isEmpty } ?? false
        )
        state = .started(startedState)
        delegate?.dynamicCheckout(didEmitEvent: .didStart)
        logger.debug("Did start dynamic checkout flow")
        // todo(andrii-vysotskyi): start non-express payment if needed
    }

    private func partitioned(
        paymentMethods: [PODynamicCheckoutPaymentMethod], expressIds: inout [String], regularIds: inout [String]
    ) -> [String: PODynamicCheckoutPaymentMethod] {
        // swiftlint:disable:next identifier_name
        var _paymentMethods: [String: PODynamicCheckoutPaymentMethod] = [:]
        for paymentMethod in paymentMethods {
            switch paymentMethod {
            case .applePay:
                if passKitPaymentInteractor.isSupported {
                    expressIds.append(paymentMethod.id)
                }
            case .alternativePayment(let alternativePaymentMethod):
                // todo(andrii-vysotskyi): ensure that only redirect APMs are express
                if alternativePaymentMethod.flow == .express {
                    expressIds.append(paymentMethod.id)
                } else {
                    regularIds.append(paymentMethod.id)
                }
            case .unknown:
                continue // todo(andrii-vysotskyi): log unknown payment method
            default:
                regularIds.append(paymentMethod.id)
            }
            _paymentMethods[paymentMethod.id] = paymentMethod
        }
        return _paymentMethods
    }

    // MARK: - Pass Kit Payment

    private func initiatePassKitPayment(methodId: String, startedState: State.Started) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState, paymentMethodId: methodId, submission: .submitting, isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        Task { @MainActor in
            do {
                try await passKitPaymentInteractor.start()
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
            submission: .possible, // Submission is initially possible
            isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
    }

    // MARK: - Alternative Payment

    private func initiateAlternativePayment(
        methodId: String, payment: PODynamicCheckoutPaymentMethod.AlternativePayment, startedState: State.Started
    ) {
        let paymentProcessingState = DynamicCheckoutInteractorState.PaymentProcessing(
            snapshot: startedState, paymentMethodId: methodId, submission: .possible, isCancellable: false
        )
        state = .paymentProcessing(paymentProcessingState)
        // todo(andrii-vysotskyi): depending on payment type non-native APM start may be needed.
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
            // todo(andrii-vysotskyi): recover non-native APM cancellation errors
            switch paymentMethod {
            case .applePay:
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

    func cardTokenization(coordinator: POCardTokenizationCoordinator, didEmitEvent event: POCardTokenizationEvent) {
        delegate?.dynamicCheckout(didEmitCardTokenizationEvent: event)
    }

    func cardTokenization(coordinator: any POCardTokenizationCoordinator, didTokenizeCard card: POCard) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
        }
        var request = POInvoiceAuthorizationRequest(invoiceId: configuration.invoiceId, source: card.id)
        let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &request)
        try await invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService)
    }

    func cardTokenization(
        coordinator: POCardTokenizationCoordinator,
        preferredSchemeFor issuerInformation: POCardIssuerInformation
    ) -> String? {
        delegate?.dynamicCheckout(preferredSchemeFor: issuerInformation)
    }

    func cardTokenization(coordinator: POCardTokenizationCoordinator, shouldContinueAfter failure: POFailure) -> Bool {
        delegate?.dynamicCheckout(shouldContinueAfter: failure) ?? true
    }

    func cardTokenization(coordinator: POCardTokenizationCoordinator, didChangeState state: POCardTokenizationState) {
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
        case .tokenizing:
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = false
        case .completed(result: .success):
            setSuccessState()
            return
        case .completed(result: .failure(let failure)):
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
            return
        }
        self.state = .paymentProcessing(paymentProcessingState)
        self.cardTokenizationCoordinator = coordinator
    }
}

extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePayment(
        coordinator: PONativeAlternativePaymentCoordinator,
        didEmitEvent event: PONativeAlternativePaymentEvent
    ) {
        delegate?.dynamicCheckout(didEmitAlternativePaymentEvent: event)
    }

    func nativeAlternativePayment(
        coordinator: PONativeAlternativePaymentCoordinator,
        defaultValuesFor parameters: [PONativeAlternativePaymentMethodParameter]
    ) async -> [String: String] {
        await delegate?.dynamicCheckout(alternativePaymentDefaultsFor: parameters) ?? [:]
    }

    func nativeAlternativePayment(
        coordinator: PONativeAlternativePaymentCoordinator,
        didChangeState state: PONativeAlternativePaymentState
    ) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state,
              case .alternativePayment = currentPaymentMethod else {
            assertionFailure("No currently active alternative payment")
            return
        }
        switch state {
        case .idle:
            break // Ignored
        case .starting:
            paymentProcessingState.submission = .unavailable
            paymentProcessingState.isCancellable = false
        case .started(let startedState):
            paymentProcessingState.submission = startedState.isSubmittable ? .possible : .temporarilyUnavailable
            paymentProcessingState.isCancellable = startedState.isCancellable
        case .submitting(let submittingState):
            paymentProcessingState.submission = .submitting
            paymentProcessingState.isCancellable = submittingState.isCancellable
        case .completed(result: .success):
            setSuccessState()
            return
        case .completed(result: .failure(let failure)):
            restoreStateAfterPaymentProcessingFailureIfPossible(failure)
            return
        }
        self.state = .paymentProcessing(paymentProcessingState)
        self.nativeAlternativePaymentCoordinator = coordinator
    }
}

// swiftlint:enable file_length
