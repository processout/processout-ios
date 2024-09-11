//
//  AlternativePaymentsInteractor.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
@_spi(PO) import ProcessOut
import ProcessOutUI

@MainActor
final class AlternativePaymentsInteractor {

    init(
        gatewayConfigurationsRepository: POGatewayConfigurationsRepository,
        invoicesService: POInvoicesService,
        alternativePaymentsService: POAlternativePaymentsService
    ) {
        self.gatewayConfigurationsRepository = gatewayConfigurationsRepository
        self.invoicesService = invoicesService
        self.alternativePaymentsService = alternativePaymentsService
        state = .idle
    }

    // MARK: - AlternativePaymentMethodsInteractor

    @Published
    private(set) var state: AlternativePaymentsInteractorState

    func start() async {
        switch state {
        case .idle, .failure:
            await setFilter(.alternativePaymentMethods)
        default:
            break
        }
    }

    func restart() async {
        switch state {
        case .idle, .failure:
            await start()
        case .starting(let currentState):
            _ = await currentState.task.result
        case .started(let started):
            await setFilter(started.filter)
        }
    }

    func setFilter(_ filter: POAllGatewayConfigurationsRequest.Filter) async {
        switch state {
        case .idle, .started, .failure:
            break
        case .starting(let currentState):
            currentState.task.cancel()
        }
        let startingStateId = UUID().uuidString
        let task = Task { @MainActor [gatewayConfigurationsRepository] in
            do {
                let request = POAllGatewayConfigurationsRequest(
                    filter: filter, paginationOptions: .init(limit: Constants.pageSize)
                )
                let response = try await gatewayConfigurationsRepository.all(request: request)
                let startedState = AlternativePaymentsInteractorState.Started(
                    gatewayConfigurations: response.gatewayConfigurations, filter: filter
                )
                state = .started(startedState)
            } catch {
                guard case .starting(let currentState) = state, currentState.id == startingStateId else {
                    return
                }
                state = .failure(error)
            }
        }
        let startingState = AlternativePaymentsInteractorState.Starting(
            id: startingStateId, filter: filter, task: task
        )
        state = .starting(startingState)
        _ = await task.result
    }

    func createInvoice(name: String, amount: Decimal, currencyCode: String) async throws -> POInvoice {
        let request = POInvoiceCreationRequest(
            name: name,
            amount: amount.description,
            currency: currencyCode,
            returnUrl: Example.Constants.returnUrl,
            customerId: Example.Constants.customerId
        )
        return try await invoicesService.createInvoice(request: request)
    }

    func authorize(invoice: POInvoice, gatewayConfigurationId: String) async throws {
        let request = POAlternativePaymentAuthorizationRequest(
            invoiceId: invoice.id, gatewayConfigurationId: gatewayConfigurationId
        )
        let response = try await alternativePaymentsService.authorize(request: request)
        let authorizationRequest = POInvoiceAuthorizationRequest(invoiceId: invoice.id, source: response.gatewayToken)
        let threeDSService = POTest3DSService()
        try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pageSize = 50
    }

    // MARK: - Private Properties

    private let gatewayConfigurationsRepository: POGatewayConfigurationsRepository
    private let invoicesService: POInvoicesService
    private let alternativePaymentsService: POAlternativePaymentsService
}
