//
//  DefaultSavedPaymentMethodsInteractorTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.01.2025.
//

import Foundation
import Testing
import SwiftUI
@testable @_spi(PO) import ProcessOut
@testable @_spi(PO) import ProcessOutUI

@MainActor
struct DefaultSavedPaymentMethodsInteractorTests {

    init() {
        let processOut = ProcessOut(
            configuration: .init(projectId: Constants.projectId, privateKey: Constants.projectPrivateKey)
        )
        invoicesService = processOut.invoices
        customerTokensService = processOut.customerTokens
    }

    // MARK: - Tests

    @Test
    func start_setsLoadingState() async throws {
        // Given
        let configuration = POSavedPaymentMethodsConfiguration(invoiceRequest: .init(invoiceId: "", clientSecret: ""))
        let sut = createInteractor(configuration: configuration)

        // When
        if case .idle = sut.state { } else {
            Issue.record("Unexpected initial state.")
        }
        sut.start()

        // Then
        if case .starting = sut.state { } else {
            Issue.record("Interactor is expected to begin starting.")
        }
    }

    @Test
    func start_whenClientSecretIsNotSet_setsLoadingState() async throws {
        // When
        let configuration = POSavedPaymentMethodsConfiguration(invoiceRequest: .init(invoiceId: ""))
        let sut = createInteractor(configuration: configuration)
        sut.start()

        // Then
        guard case .starting(let startingState) = sut.state else {
            Issue.record("Interactor state is expected to be starting.")
            return
        }

        // Then
        _ = await startingState.task.result
        if case .completed(let result) = sut.state {
            withKnownIssue {
                try result.get()
            }
        } else {
            Issue.record("Interactor state is expected to be completed.")
        }
    }

    // MARK: - Private Properties

    private let invoicesService: POInvoicesService
    private let customerTokensService: POCustomerTokensService

    // MARK: - Private Methods

    private func createInteractor(
        configuration: POSavedPaymentMethodsConfiguration,
        completion: @escaping (Result<Void, POFailure>) -> Void = { _ in }
    ) -> any SavedPaymentMethodsInteractor {
        let interactor = DefaultSavedPaymentMethodsInteractor(
            configuration: configuration,
            invoicesService: invoicesService,
            customerTokensService: customerTokensService,
            logger: .stub,
            completion: completion
        )
        return interactor
    }
}
