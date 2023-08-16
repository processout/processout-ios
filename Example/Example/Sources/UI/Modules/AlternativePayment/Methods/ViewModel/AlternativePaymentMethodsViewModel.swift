//
//  AlternativePaymentMethodsViewModel.swift
//  Example
//
//  Created by Andrii Vysotskyi on 29.10.2022.
//

import Foundation
@_spi(PO) import ProcessOut

final class AlternativePaymentMethodsViewModel:
    BaseViewModel<AlternativePaymentMethodsViewModelState>, AlternativePaymentMethodsViewModelType {

    init(
        interactor: any AlternativePaymentMethodsInteractorType,
        router: any RouterType<AlternativePaymentMethodsRoute>,
        prefersNative: Bool
    ) {
        self.interactor = interactor
        self.router = router
        self.prefersNative = prefersNative
        super.init(state: .idle)
        observeInteractorStateChanges()
    }

    // MARK: - AlternativePaymentMethodsViewModelType

    override func start() {
        interactor.start()
    }

    func restart() {
        interactor.restart()
    }

    func loadMore() {
        interactor.loadMore()
    }

    // MARK: - Private Properties

    private let interactor: any AlternativePaymentMethodsInteractorType
    private let router: any RouterType<AlternativePaymentMethodsRoute>
    private let prefersNative: Bool

    // MARK: - Private Methods

    private func observeInteractorStateChanges() {
        interactor.didChange = { [weak self] in self?.configureWithInteractorState() }
    }

    private func configureWithInteractorState() {
        switch interactor.state {
        case .idle:
            state = .idle
        case .starting:
            let state = State.Started(items: [], areOperationsExecuting: true)
            self.state = .started(state)
        case .started(let startedState):
            state = convertToState(startedState: startedState, areOperationsExecuting: false)
        case .loadingMore(let loadingMoreState):
            state = convertToState(loadingMoreState: loadingMoreState)
        case .restarting(let snapshot):
            state = convertToState(startedState: snapshot, areOperationsExecuting: true)
        case .creatingInvoice(let snapshot):
            state = convertToState(startedState: snapshot, areOperationsExecuting: true)
        case .failure(let failure):
            let failureItem = State.FailureItem(
                description: failure.message ?? Strings.AlternativePaymentMethods.Failure.unknown
            )
            let state = State.Started(items: [.failure(failureItem)], areOperationsExecuting: false)
            self.state = .started(state)
        }
    }

    private func convertToState(
        startedState: AlternativePaymentMethodsInteractorState.Started, areOperationsExecuting: Bool
    ) -> State {
        let state = State.Started(
            items: startedState.gatewayConfigurations.map(convertToItem), areOperationsExecuting: areOperationsExecuting
        )
        return .started(state)
    }

    private func convertToState(loadingMoreState: AlternativePaymentMethodsInteractorState.LoadingMore) -> State {
        let state = State.Started(
            items: loadingMoreState.gatewayConfigurations.map(convertToItem), areOperationsExecuting: true
        )
        return .started(state)
    }

    private func convertToItem(gatewayConfiguration: POGatewayConfiguration) -> State.Item {
        let item = State.ConfigurationItem(
            id: AnyHashable(gatewayConfiguration.id),
            name: gatewayConfiguration.gateway?.displayName ?? Strings.AlternativePaymentMethods.Gateway.unknown,
            select: { [weak self] in
                let route = AlternativePaymentMethodsRoute.authorizationtAmount { amount, currencyCode in
                    self?.startNativeAlternativePayment(
                        amount: amount, currencyCode: currencyCode, gatewayConfiguration: gatewayConfiguration
                    )
                }
                self?.router.trigger(route: route)
            }
        )
        return State.Item.configuration(item)
    }

    // MARK: -

    private func startNativeAlternativePayment(
        amount: Decimal, currencyCode: String, gatewayConfiguration: POGatewayConfiguration
    ) {
        // Invoice is created inside application only for demo purposes. Production application should rely on backend
        // to create invoice. To ensure that customer can't alter such values as amount and currency.
        interactor.createInvoice(amount: amount, currencyCode: currencyCode) { [weak self, prefersNative] invoice in
            let route: AlternativePaymentMethodsRoute
            let isSubaccount = gatewayConfiguration
                .subAccountsEnabled?
                .contains(gatewayConfiguration.gatewayName ?? "") ?? false
            if !isSubaccount {
                return
            } else if prefersNative {
                let paymentRoute = AlternativePaymentMethodsRoute.NativeAlternativePayment(
                    gatewayConfigurationId: gatewayConfiguration.id,
                    invoiceId: invoice.id,
                    completion: { [weak self] result in
                        self?.didCompleteNativePayment(result: result)
                    }
                )
                route = .nativeAlternativePayment(paymentRoute)
            } else {
                route = AlternativePaymentMethodsRoute.additionalData { [weak self] additionalData in
                    let request = POAlternativePaymentMethodRequest(
                        invoiceId: invoice.id,
                        gatewayConfigurationId: gatewayConfiguration.id,
                        additionalData: additionalData
                    )
                    self?.router.trigger(route: .alternativePayment(request: request))
                }
            }
            self?.router.trigger(route: route)
        }
    }

    private func didCompleteNativePayment(result: Result<Void, POFailure>) {
        // Success is already a part of native alternative payment module so ignored here.
        guard case let .failure(failure) = result else {
            return
        }
        let message: String
        if let failureMessage = failure.message, !failureMessage.isEmpty {
            message = Strings.AlternativePaymentMethods.Result.failureMessage(failureMessage)
        } else {
            message = Strings.AlternativePaymentMethods.Result.defaultFailureMessage
        }
        router.trigger(route: .alert(message: message))
    }
}
