//
//  AlternativePaymentsInteractor.swift
//  Example
//
//  Created by Andrii Vysotskyi on 28.10.2022.
//

import Foundation
@_spi(PO) import ProcessOut

@MainActor
final class AlternativePaymentsInteractor {

    init(gatewayConfigurationsRepository: POGatewayConfigurationsRepository, invoicesService: POInvoicesService) {
        self.gatewayConfigurationsRepository = gatewayConfigurationsRepository
        self.invoicesService = invoicesService
        state = .idle
    }

    // MARK: - AlternativePaymentMethodsInteractor

    @Published
    private(set) var state: AlternativePaymentsInteractorState

    func start() async {
        switch state {
        case .idle, .failure:
            break
        default:
            return
        }
        state = .starting
        do {
            try await setStartedStateUnchecked()
        } catch {
            state = .failure(error)
        }
    }

    func restart() async {
        switch state {
        case .failure:
            await start()
        case .started(let currentState):
            state = .restarting(snapshot: currentState)
            do {
                try await setStartedStateUnchecked()
            } catch {
                state = .started(currentState) // Error is ignored
            }
        default:
            break // Ignored
        }
    }

    func createInvoice(amount: Decimal, currencyCode: String) async throws -> POInvoice {
        let request = POInvoiceCreationRequest(
            name: UUID().uuidString,
            amount: amount.description,
            currency: currencyCode,
            returnUrl: Example.Constants.returnUrl,
            customerId: Example.Constants.customerId
        )
        return try await invoicesService.createInvoice(request: request)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let pageSize = 100
    }

    // MARK: - Private Properties

    private let gatewayConfigurationsRepository: POGatewayConfigurationsRepository
    private let invoicesService: POInvoicesService

    // MARK: - Private Methods

    private func setStartedStateUnchecked() async throws {
        let request = POAllGatewayConfigurationsRequest(
            filter: nil, paginationOptions: .init(limit: Constants.pageSize)
        )
        let response = try await gatewayConfigurationsRepository.all(request: request)
        let startedState = AlternativePaymentsInteractorState.Started(
            gatewayConfigurations: response.gatewayConfigurations, filter: nil
        )
        state = .started(startedState)
    }
}
