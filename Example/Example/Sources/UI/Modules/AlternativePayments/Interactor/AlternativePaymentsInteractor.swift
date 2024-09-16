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
        alternativePaymentsService: POAlternativePaymentsService,
        tokensService: POCustomerTokensService
    ) {
        self.gatewayConfigurationsRepository = gatewayConfigurationsRepository
        self.invoicesService = invoicesService
        self.alternativePaymentsService = alternativePaymentsService
        self.tokensService = tokensService
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

    func invoice(id: String) async throws -> POInvoice {
        let request = POInvoiceRequest(invoiceId: id, attachPrivateKey: true)
        return try await invoicesService.invoice(request: request)
    }

    func createInvoice(amount: Decimal, currencyCode: String) async throws -> POInvoice {
        let request = POInvoiceCreationRequest(
            name: UUID().uuidString,
            amount: amount,
            currency: currencyCode,
            returnUrl: Example.Constants.returnUrl,
            customerId: Example.Constants.customerId,
            details: [
                .init(name: "Test", amount: amount, quantity: 1)
            ]
        )
        return try await invoicesService.createInvoice(request: request)
    }

    func authorize(invoice: POInvoice, gatewayConfigurationId: String) async throws {
        let request = POAlternativePaymentAuthorizationRequest(
            invoiceId: invoice.id, gatewayConfigurationId: gatewayConfigurationId
        )
        let response = try await alternativePaymentsService.authorize(request: request)
        let authorizationRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoice.id,
            source: response.gatewayToken,
            allowFallbackToSale: true
        )
        let threeDSService = POTest3DSService(returnUrl: Example.Constants.returnUrl)
        try await invoicesService.authorizeInvoice(request: authorizationRequest, threeDSService: threeDSService)
    }

    func tokenize(gatewayConfigurationId: String) async throws -> POCustomerToken {
        let tokenCreationRequest = POCreateCustomerTokenRequest(
            customerId: Example.Constants.customerId,
            verify: true,
            returnUrl: Example.Constants.returnUrl
        )
        let token = try await tokensService.createCustomerToken(request: tokenCreationRequest)
        let tokenizationRequest = POAlternativePaymentTokenizationRequest(
            customerId: Example.Constants.customerId,
            customerTokenId: token.id,
            gatewayConfigurationId: gatewayConfigurationId
        )
        let tokenAssignRequest = POAssignCustomerTokenRequest(
            customerId: Example.Constants.customerId,
            tokenId: token.id,
            source: try await alternativePaymentsService.tokenize(request: tokenizationRequest).gatewayToken
        )
        let threeDSService = POTest3DSService(returnUrl: Example.Constants.returnUrl)
        return try await tokensService.assignCustomerToken(request: tokenAssignRequest, threeDSService: threeDSService)
    }

    func authorize(invoice: POInvoice, customerToken: POCustomerToken) async throws {
        let invoiceAuthorizationRequest = POInvoiceAuthorizationRequest(
            invoiceId: invoice.id,
            source: customerToken.id,
            allowFallbackToSale: true
        )
        let threeDSService = POTest3DSService(returnUrl: Example.Constants.returnUrl)
        try await invoicesService.authorizeInvoice(request: invoiceAuthorizationRequest, threeDSService: threeDSService)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pageSize = 50
    }

    // MARK: - Private Properties

    private let gatewayConfigurationsRepository: POGatewayConfigurationsRepository
    private let invoicesService: POInvoicesService
    private let alternativePaymentsService: POAlternativePaymentsService
    private let tokensService: POCustomerTokensService
}
