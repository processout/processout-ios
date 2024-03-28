//
//  DynamicCheckoutDefaultInteractor.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 05.03.2024.
//

import Foundation
@_spi(PO) import ProcessOut

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
        state = .starting
        Task {
            await continueStartUnchecked()
        }
    }

    func initiatePayment(methodId: String) -> Bool {
        // todo(andrii-vysotskyi): support changing payment method when already paying
        guard case .started(let startedState) = state else {
            return false
        }
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
    }

    func submit() {
        guard case .paymentProcessing(let paymentProcessingState) = state else {
            return
        }
        let paymentMethods = paymentProcessingState.snapshot.paymentMethods
        guard let paymentMethod = paymentMethods[paymentProcessingState.paymentMethodId] else {
            assertionFailure("Unknown payment method ID.")
            return
        }
        switch paymentMethod {
        case .card:
            cardTokenizationCoordinator?.tokenize()
        case .alternativePayment:
            // todo(andrii-vysotskyi): validate whether payment is native
            nativeAlternativePaymentCoordinator?.submit()
        default:
            assertionFailure("Active payment method doesn't support forced submission.")
        }
    }

    func cancel() {
        guard case .paymentProcessing(let paymentProcessingState) = state else {
            return
        }
        let paymentMethods = paymentProcessingState.snapshot.paymentMethods
        guard let paymentMethod = paymentMethods[paymentProcessingState.paymentMethodId] else {
            assertionFailure("Unknown payment method ID.")
            return
        }
        switch paymentMethod {
        case .card:
            cardTokenizationCoordinator?.cancel()
        case .alternativePayment:
            // todo(andrii-vysotskyi): validate whether payment is native
            nativeAlternativePaymentCoordinator?.cancel()
        default:
            assertionFailure("Active payment method doesn't support cancellation.")
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
                expressIds.append(paymentMethod.id)
            case .alternativePayment(let alternativePaymentMethod):
                // todo(andrii-vysotskyi): ensure that only redirect APMs are express
                if alternativePaymentMethod.flow == .express {
                    expressIds.append(paymentMethod.id)
                } else {
                    regularIds.append(paymentMethod.id)
                }
            case .unknown:
                break // todo(andrii-vysotskyi): log unknown payment method
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
                state = .success(snapshot: paymentProcessingState)
            } catch {
                restoreStartedStateAfterPaymentProcessingFailureIfPossible(error)
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
    private func restoreStartedStateAfterPaymentProcessingFailureIfPossible(_ error: Error) {
        logger.info("Did fail to process payment: \(error)")
        guard let failure = error as? POFailure, case .cancelled = failure.code else {
            setFailureStateUnchecked(error: error)
            return
        }
        let startedState: State.Started
        switch state {
        case .paymentProcessing(let paymentProcessingState):
            startedState = paymentProcessingState.snapshot
        default:
            setFailureStateUnchecked(error: error)
            return
        }
        state = .started(startedState)
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

    // MARK: - Events

    private func send(event: PODynamicCheckoutEvent) {
        assert(Thread.isMainThread, "Method should be called on main thread.")
        logger.debug("Did send event: '\(event)'")
        delegate?.dynamicCheckout(didEmitEvent: event)
    }
}

// todo(andrii-vysotskyi): forward other delegate methods
extension DynamicCheckoutDefaultInteractor: POCardTokenizationDelegate {

    func cardTokenization(coordinator: any POCardTokenizationCoordinator, didTokenizeCard card: POCard) async throws {
        guard let delegate else {
            throw POFailure(message: "Delegate must be set to authorize invoice.", code: .generic(.mobile))
        }
        var request = POInvoiceAuthorizationRequest(invoiceId: configuration.invoiceId, source: card.id)
        let threeDSService = await delegate.dynamicCheckout(willAuthorizeInvoiceWith: &request)
        try await invoicesService.authorizeInvoice(request: request, threeDSService: threeDSService)
    }

    func cardTokenization(coordinator: POCardTokenizationCoordinator, didChangeState state: POCardTokenizationState) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state else {
            return
        }
        let paymentMethods = paymentProcessingState.snapshot.paymentMethods
        guard case .card = paymentMethods[paymentProcessingState.paymentMethodId] else {
            assertionFailure("Unexpected current payment method.")
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
        case .completed:
            paymentProcessingState.submission = .unavailable
            paymentProcessingState.isCancellable = false
        }
        self.state = .paymentProcessing(paymentProcessingState)
        self.cardTokenizationCoordinator = coordinator
    }
}

// todo(andrii-vysotskyi): forward other delegate methods
extension DynamicCheckoutDefaultInteractor: PONativeAlternativePaymentDelegate {

    func nativeAlternativePayment(
        coordinator: PONativeAlternativePaymentCoordinator,
        didChangeState state: PONativeAlternativePaymentState
    ) {
        guard case .paymentProcessing(var paymentProcessingState) = self.state else {
            return
        }
        let paymentMethods = paymentProcessingState.snapshot.paymentMethods
        guard case .alternativePayment = paymentMethods[paymentProcessingState.paymentMethodId] else {
            assertionFailure("Unexpected current payment method.")
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
        case .completed:
            paymentProcessingState.submission = .unavailable
            paymentProcessingState.isCancellable = false
        }
        self.state = .paymentProcessing(paymentProcessingState)
        self.nativeAlternativePaymentCoordinator = coordinator
    }
}
