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
            do throws(POFailure) {
                let invoice = try await invoicesService.invoice(request: configuration.invoiceRequest)
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
        setFailureState(POFailure(code: .Mobile.cancelled))
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

    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService
    private let logger: POLogger
    private let completion: (Result<Void, POFailure>) -> Void

    // MARK: - Failure State

    private func setFailureState(_ error: POFailure) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set completed state with: \(error).")
        } else {
            state = .completed(.failure(error))
            completion(.failure(error))
        }
    }

    // MARK: - Started State

    private func setStartedState(invoice: POInvoice) {
        guard case .starting = state else {
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
        state = .started(.init(paymentMethods: paymentMethods, customerId: customerId, recentFailure: nil))
    }

    private func setStartedState(afterDeletionError error: POFailure) {
        guard case .removing(let currentState) = state else {
            return
        }
        let nextState = State.Started(
            paymentMethods: currentState.startedStateSnapshot.paymentMethods,
            customerId: currentState.startedStateSnapshot.customerId,
            recentFailure: error
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
                clientSecret: configuration.invoiceRequest.clientSecret ?? ""
            )
            do throws(POFailure) {
                try await customerTokensService.deleteCustomerToken(request: request)
                deletePendingRemovalCustomerTokens()
            } catch {
                setStartedState(afterDeletionError: error)
            }
        }
        var nextStartedStateSnapshot = startedState
        nextStartedStateSnapshot.recentFailure = nil
        let nextState = State.Removing(
            startedStateSnapshot: nextStartedStateSnapshot,
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
            description: customerToken.display.description,
            deletingAllowed: customerToken.configuration.deletingAllowed
        )
        return paymentMethod
    }
}
