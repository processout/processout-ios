//
//  DefaultSavedPaymentMethodsInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

@_spi(PO) import ProcessOut

final class DefaultSavedPaymentMethodsInteractor:
    BaseInteractor<SavedPaymentMethodsInteractorState>, SavedPaymentMethodsInteractor {

    init(
        configuration: POSavedPaymentMethodsConfiguration,
        delegate: POSavedPaymentMethodsDelegate?,
        invoicesService: POInvoicesService,
        customerTokensService: POCustomerTokensService,
        logger: POLogger,
        completion: @escaping (Result<Void, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.invoicesService = invoicesService
        self.customerTokensService = customerTokensService
        self.completion = completion
        self.logger = logger
        super.init(state: .idle)
    }

    // MARK: - SavedPaymentMethodsInteractor

    let configuration: POSavedPaymentMethodsConfiguration

    override func start() {
        guard case .idle = state else {
            logger.debug("Ignoring attempt to start interactor in unsupported state: \(state).")
            return
        }
        let task = Task { [invoicesService] in
            guard configuration.invoiceRequest.clientSecret != nil else {
                let failure = POFailure(
                    message: "Client secret must be set to access customer's payment methods.", code: .Mobile.generic
                )
                setFailureState(failure)
                return
            }
            do {
                let invoice = try await invoicesService.invoice(request: configuration.invoiceRequest)
                setStartedState(invoice: invoice)
            } catch {
                setFailureState(error)
            }
        }
        logger.debug("Will start interactor.")
        state = .starting(.init(task: task))
        delegate?.savedPaymentMethods(didEmitEvent: .willStart)
    }

    override func cancel() {
        switch state {
        case .starting(let currentState):
            currentState.task.cancel()
        case .removing(let currentState):
            currentState.task.cancel()
        default:
            break
        }
        setFailureState(POFailure(code: .Mobile.cancelled))
    }

    func delete(customerTokenId: String) {
        switch state {
        case .started(let currentState):
            logger.debug("Will remove payment method.", attributes: [.customerTokenId: customerTokenId])
            unsafeSetRemovingState(customerTokenId: customerTokenId, startedState: currentState)
        case .removing(let currentState):
            logger.debug("Queue payment method removal.", attributes: [.customerTokenId: customerTokenId])
            var nextState = currentState
            nextState.pendingRemovalCustomerTokenIds.append(customerTokenId)
            state = .removing(nextState)
        default:
            logger.error(
                "Ignoring attempt to delete payment method in unsupported state: \(state).",
                attributes: [.customerTokenId: customerTokenId]
            )
        }
    }

    func didRequestRemovalConfirmation(customerTokenId: String) {
        let paymentMethods: [State.PaymentMethod]
        switch state {
        case .started(let currentState):
            paymentMethods = currentState.paymentMethods
        case .removing(let currentState):
            paymentMethods = currentState.startedStateSnapshot.paymentMethods
        default:
            logger.error("Unsupported state: \(state).", attributes: [.customerTokenId: customerTokenId])
            return
        }
        let paymentMethod = paymentMethods.first { $0.configuration.customerTokenId == customerTokenId }
        guard let paymentMethod else {
            logger.error("Unknown payment method ID.", attributes: [.customerTokenId: customerTokenId])
            return
        }
        logger.debug("Did request removal confirmation.", attributes: [.customerTokenId: customerTokenId])
        delegate?.savedPaymentMethods(didEmitEvent: .didRequestDeleteConfirmation(paymentMethod))
    }

    // MARK: - Private Properties

    private weak var delegate: POSavedPaymentMethodsDelegate?
    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService
    private var logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - Failure State

    private func setFailureState(_ error: Error) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set completed state with: \(error).")
        } else {
            let failure = self.failure(with: error)
            logger.info("Did complete with error: \(failure).")
            state = .completed(.failure(failure))
            delegate?.savedPaymentMethods(didEmitEvent: .didComplete(.failure(failure)))
            completion(.failure(failure))
        }
    }

    // MARK: - Started State

    private func setStartedState(invoice: POInvoice) {
        guard case .starting = state else {
            logger.error("Ignoring attempt to set started state in unsupported state: \(state).")
            return
        }
        guard let customerId = invoice.customerId else {
            let failure = POFailure(message: "Unable to start interactor without customer ID.", code: .Mobile.generic)
            setFailureState(failure)
            return
        }
        let paymentMethods = invoice.paymentMethods?.compactMap { paymentMethod in
            self.paymentMethod(with: paymentMethod)
        } ?? []
        logger[attributeKey: .customerId] = invoice.customerId
        logger.debug("Did start interactor with payment methods: \(paymentMethods).")
        state = .started(.init(paymentMethods: paymentMethods, customerId: customerId, recentFailure: nil))
        delegate?.savedPaymentMethods(didEmitEvent: .didStart(.init(paymentMethods: paymentMethods)))
    }

    private func setStartedState(afterDeletionError error: Error) {
        guard case .removing(let currentState) = state else {
            return
        }
        let failure = self.failure(with: error)
        let nextState = State.Started(
            paymentMethods: currentState.startedStateSnapshot.paymentMethods,
            customerId: currentState.startedStateSnapshot.customerId,
            recentFailure: failure
        )
        logger.warn(
            "Did fail to delete payment method: \(error).",
            attributes: [.customerTokenId: currentState.removedPaymentMethod.configuration.customerTokenId]
        )
        state = .started(nextState)
        delegate?.savedPaymentMethods(didEmitEvent: .didDeletePaymentMethod(
            .init(paymentMethod: currentState.removedPaymentMethod, result: .failure(failure))
        ))
    }

    // MARK: -

    private func deletePendingRemovalCustomerTokens() {
        guard case .removing(let currentState) = state else {
            return
        }
        let nextStartedState = State.Started(
            paymentMethods: currentState.startedStateSnapshot.paymentMethods.filter { paymentMethod in
                paymentMethod.id != currentState.removedPaymentMethod.id
            },
            customerId: currentState.startedStateSnapshot.customerId,
            recentFailure: nil
        )
        if currentState.pendingRemovalCustomerTokenIds.isEmpty {
            state = .started(nextStartedState)
        } else {
            var pendingRemovalCustomerTokenIds = currentState.pendingRemovalCustomerTokenIds
            unsafeSetRemovingState(
                customerTokenId: pendingRemovalCustomerTokenIds.removeFirst(),
                startedState: nextStartedState,
                pendingRemovalCustomerTokenIds: pendingRemovalCustomerTokenIds
            )
        }
    }

    private func unsafeSetRemovingState(
        customerTokenId: String,
        startedState: State.Started,
        pendingRemovalCustomerTokenIds: [String] = []
    ) {
        guard let removedPaymentMethod = startedState.paymentMethods.first(where: { $0.id == customerTokenId }) else {
            logger.error(
                "Ignoring attempt to delete unknown payment method.", attributes: [.customerTokenId: customerTokenId]
            )
            return
        }
        let task = Task {
            let request = PODeleteCustomerTokenRequest(
                customerId: startedState.customerId,
                tokenId: customerTokenId,
                clientSecret: configuration.invoiceRequest.clientSecret ?? ""
            )
            do {
                try await customerTokensService.deleteCustomerToken(request: request)
                logger.debug("Did delete payment method.", attributes: [.customerTokenId: customerTokenId])
                delegate?.savedPaymentMethods(didEmitEvent: .didDeletePaymentMethod(
                    .init(paymentMethod: removedPaymentMethod, result: .success(()))
                ))
                deletePendingRemovalCustomerTokens()
            } catch {
                setStartedState(afterDeletionError: error)
            }
        }
        var nextStartedStateSnapshot = startedState
        nextStartedStateSnapshot.recentFailure = nil
        let nextState = State.Removing(
            startedStateSnapshot: nextStartedStateSnapshot,
            removedPaymentMethod: removedPaymentMethod,
            task: task,
            pendingRemovalCustomerTokenIds: pendingRemovalCustomerTokenIds
        )
        state = .removing(nextState)
        logger.debug("Will delete payment method.")
        delegate?.savedPaymentMethods(didEmitEvent: .willDeletePaymentMethod(removedPaymentMethod))
    }

    // MARK: - Utils

    private func paymentMethod(with paymentMethod: PODynamicCheckoutPaymentMethod) -> State.PaymentMethod? {
        guard case .customerToken(let customerToken) = paymentMethod else {
            return nil
        }
        return customerToken
    }

    private func failure(with error: Error) -> POFailure {
        if let failure = error as? POFailure {
            return failure
        }
        return POFailure(message: "Something went wrong.", code: .Mobile.generic, underlyingError: error)
    }
}
