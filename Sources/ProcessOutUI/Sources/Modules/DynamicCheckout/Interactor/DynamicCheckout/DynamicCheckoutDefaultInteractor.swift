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
        delegate: PODynamicCheckoutDelegate,
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
        // todo(andrii-vysotskyi): implement me
        false
    }

    func submit() {
        // todo(andrii-vysotskyi): implement me
    }

    func cancel() {
        // todo(andrii-vysotskyi): implement me
    }

    // MARK: - Private Properties

    private let configuration: PODynamicCheckoutConfiguration
    private let invoicesService: POInvoicesService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    private let passKitPaymentInteractor: DynamicCheckoutPassKitPaymentInteractor
    private let alternativePaymentInteractor: DynamicCheckoutAlternativePaymentInteractor

    private weak var delegate: PODynamicCheckoutDelegate?
    private weak var alternativePaymentCoordinator: PONativeAlternativePaymentCoordinator?

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
