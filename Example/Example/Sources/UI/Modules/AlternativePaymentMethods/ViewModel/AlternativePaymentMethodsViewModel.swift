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
        router: any RouterType<AlternativePaymentMethodsRoute>
    ) {
        self.interactor = interactor
        self.router = router
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
                self?.createAndAuthorizeInvoice(gatewayConfiguration: gatewayConfiguration)
            }
        )
        return State.Item.configuration(item)
    }

    // MARK: -

    private func createAndAuthorizeInvoice(gatewayConfiguration: POGatewayConfiguration) {
        interactor.createInvoice(currencyCode: gatewayConfiguration.defaultCurrency) { [weak self] invoice in
            let route: AlternativePaymentMethodsRoute
            let isSubaccount = gatewayConfiguration
                .subAccountsEnabled?
                .contains(gatewayConfiguration.gatewayName ?? "") ?? false
            if !isSubaccount {
                return
            } else if gatewayConfiguration.gateway?.nativeApmConfig != nil {
                route = .nativeAlternativePayment(
                    gatewayConfigurationId: gatewayConfiguration.id, invoiceId: invoice.id
                )
            } else {
                let request = POAlternativePaymentMethodRequest(
                    invoiceId: invoice.id, gatewayConfigurationId: gatewayConfiguration.id
                )
                route = .alternativePayment(request: request)
            }
            self?.router.trigger(route: route)
        }
    }
}
