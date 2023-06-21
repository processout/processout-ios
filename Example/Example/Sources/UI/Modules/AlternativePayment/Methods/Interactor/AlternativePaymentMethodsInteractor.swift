//
//  AlternativePaymentMethodsInteractor.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
@_spi(PO) import ProcessOut

final class AlternativePaymentMethodsInteractor:
    BaseInteractor<AlternativePaymentMethodsInteractorState>, AlternativePaymentMethodsInteractorType {

    init(
        gatewayConfigurationsRepository: POGatewayConfigurationsRepository,
        invoicesService: POInvoicesService,
        filter: POAllGatewayConfigurationsRequest.Filter?
    ) {
        self.gatewayConfigurationsRepository = gatewayConfigurationsRepository
        self.invoicesService = invoicesService
        self.filter = filter
        super.init(state: .idle)
    }

    // MARK: - AlternativePaymentMethodsInteractorType

    override func start() {
        switch state {
        case .idle, .failure:
            break
        default:
            return
        }
        state = .starting
        let request = POAllGatewayConfigurationsRequest(
            filter: filter, paginationOptions: .init(limit: Constants.pageSize)
        )
        gatewayConfigurationsRepository.all(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.setStartedStateUnchecked(response: response)
            case .failure(let failure):
                self?.state = .failure(failure)
            }
        }
    }

    func restart() {
        guard case .started(let startedState) = state else {
            start()
            return
        }
        state = .restarting(snapshot: startedState)
        let request = POAllGatewayConfigurationsRequest(
            filter: filter, paginationOptions: .init(limit: Constants.pageSize)
        )
        gatewayConfigurationsRepository.all(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                self?.setStartedStateUnchecked(response: response)
            case .failure:
                self?.state = .started(startedState)
            }
        }
    }

    func loadMore() {
        guard case .started(let startedState) = state,
              startedState.areMoreAvaiable,
              let gatewayConfiguration = startedState.gatewayConfigurations.last else {
            return
        }
        let loadingMore = State.LoadingMore(gatewayConfigurations: startedState.gatewayConfigurations)
        state = .loadingMore(loadingMore)
        let request = POAllGatewayConfigurationsRequest(
            filter: filter,
            paginationOptions: .init(position: .after(gatewayConfiguration.id), limit: Constants.pageSize)
        )
        gatewayConfigurationsRepository.all(request: request) { [weak self] result in
            switch result {
            case .success(let response):
                let updatedStartedState = State.Started(
                    gatewayConfigurations: startedState.gatewayConfigurations + response.gatewayConfigurations,
                    areMoreAvaiable: response.hasMore
                )
                self?.state = .started(updatedStartedState)
            case .failure:
                self?.state = .started(startedState)
            }
        }
    }

    func createInvoice(amount: Decimal, currencyCode: String, success: @escaping (POInvoice) -> Void) {
        guard case .started(let startedState) = state else {
            return
        }
        state = .creatingInvoice(snapshot: startedState)
        let request = POInvoiceCreationRequest(
            name: UUID().uuidString,
            amount: amount.description,
            currency: currencyCode,
            returnUrl: Example.Constants.returnUrl
        )
        invoicesService.createInvoice(request: request) { [weak self] result in
            self?.state = .started(startedState)
            guard case .success(let invoice) = result else {
                return
            }
            success(invoice)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pageSize = 20
    }

    // MARK: - Private Properties

    private let gatewayConfigurationsRepository: POGatewayConfigurationsRepository
    private let invoicesService: POInvoicesService
    private let filter: POAllGatewayConfigurationsRequest.Filter?

    // MARK: - State Management

    private func setStartedStateUnchecked(response: POAllGatewayConfigurationsResponse) {
        let startedState = State.Started(
            gatewayConfigurations: response.gatewayConfigurations,
            areMoreAvaiable: response.hasMore
        )
        state = .started(startedState)
    }
}
