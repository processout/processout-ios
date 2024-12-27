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

    override func start() {
        guard case .idle = state else {
            logger.debug("Ignoring attempt to start interactor in unsupported state: \(state).")
            return
        }
        let task = Task { [invoicesService] in
            do {
                let invoiceRequest = POInvoiceRequest(
                    invoiceId: configuration.invoiceId, clientSecret: configuration.clientSecret
                )
                let invoice = try await invoicesService.invoice(request: invoiceRequest)
                setStartedState(invoice: invoice)
            } catch {
                setFailureState(error)
            }
        }
        state = .starting(.init(task: task))
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
        setFailureState(POFailure(code: .cancelled))
    }

    func delete(customerTokenId: String) {
        switch state {
        case .started(let currentState):
            unsafeSetRemovingState(customerTokenId: customerTokenId, startedState: currentState)
        case .removing(let currentState):
            guard !currentState.pendingRemovalCustomerTokenIds.contains(customerTokenId) else {
                return
            }
            var nextState = currentState
            nextState.pendingRemovalCustomerTokenIds.append(customerTokenId)
            state = .removing(nextState)
        default:
            logger.error("Ignoring attempt to remove.")
        }
    }

    // MARK: - Private Properties

    private let configuration: POSavedPaymentMethodsConfiguration
    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - Failure State

    private func setFailureState(_ error: Error) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set completed state with: \(error).")
        } else {
            let failure = self.failure(with: error)
            state = .completed(.failure(failure))
            completion(.failure(failure))
        }
    }

    // MARK: - Started State

    private func setStartedState(invoice: POInvoice) {
        guard case .starting = state else {
            return
        }
        let paymentMethods = invoice.paymentMethods?.compactMap { paymentMethod in
            self.paymentMethod(with: paymentMethod)
        }
        if let customerId = invoice.customerId, let paymentMethods, !paymentMethods.isEmpty {
            state = .started(.init(paymentMethods: paymentMethods, customerId: customerId, recentFailure: nil))
        } else {
            let message = "Unable to start interactor. Payment methods and customer ID must be set."
            let failure = POFailure(message: message, code: .generic(.mobile))
            setFailureState(failure)
        }
    }

    private func setStartedState(afterDeletionError error: Error) {
        guard case .removing(let currentState) = state else {
            return
        }
        let nextState = State.Started(
            paymentMethods: currentState.startedStateSnapshot.paymentMethods,
            customerId: currentState.startedStateSnapshot.customerId,
            recentFailure: failure(with: error)
        )
        state = .started(nextState)
    }

    // MARK: -

    private func deletePendingRemovalCustomerTokens() {
        guard case .removing(let currentState) = state else {
            return
        }
        let nextStartedState = State.Started(
            paymentMethods: currentState.startedStateSnapshot.paymentMethods.filter { paymentMethod in
                paymentMethod.customerTokenId != currentState.removedCustomerTokenId
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
        let task = Task {
            let request = PODeleteCustomerTokenRequest(
                customerId: startedState.customerId,
                tokenId: customerTokenId,
                clientSecret: configuration.clientSecret
            )
            do {
                try await customerTokensService.deleteCustomerToken(request: request)
                deletePendingRemovalCustomerTokens()
            } catch {
                setStartedState(afterDeletionError: error)
            }
        }
        let nextState = State.Removing(
            startedStateSnapshot: startedState,
            removedCustomerTokenId: customerTokenId,
            task: task,
            pendingRemovalCustomerTokenIds: pendingRemovalCustomerTokenIds
        )
        state = .removing(nextState)
    }

    // MARK: - Utils

    private func paymentMethod(with paymentMethod: PODynamicCheckoutPaymentMethod) -> State.PaymentMethod? {
        guard case .customerToken(let customerToken) = paymentMethod else {
            return nil
        }
        let paymentMethod = State.PaymentMethod(
            customerTokenId: customerToken.id,
            logo: customerToken.display.logo,
            name: customerToken.display.name,
            description: customerToken.display.description
        )
        return paymentMethod
    }

    private func failure(with error: Error) -> POFailure {
        if let failure = error as? POFailure {
            return failure
        }
        return POFailure(message: "Something went wrong.", code: .generic(.mobile), underlyingError: error)
    }
}
