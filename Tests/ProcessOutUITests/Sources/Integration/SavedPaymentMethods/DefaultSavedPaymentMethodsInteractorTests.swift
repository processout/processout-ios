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
        cardsService = processOut.cards
        invoicesService = processOut.invoices
        customersService = processOut.customers
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
    func start_whenClientSecretIsNotSet_completesWithFailure() async throws {
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

    @Test
    func start_whenCustomerDoesntHaveCustomerTokens_starts() async throws {
        // Given
        let customer = try await customersService.createCustomer(
            request: .init()
        )
        let invoice = try await invoicesService.createInvoice(
            request: .init(name: UUID().uuidString, amount: 1, currency: "USD", customerId: customer.id)
        )
        let sut = createInteractor(
            configuration: .init(invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret))
        )
        await start(interactor: sut)

        // Then
        guard case .started(let startedState) = sut.state else {
            Issue.record("Interactor state is expected to be started.")
            return
        }
        #expect(startedState.customerId == customer.id)
        #expect(startedState.paymentMethods.isEmpty)
    }

    @Test
    func start_whenCustomerHasTokens_starts() async throws {
        // Given
        let customer = try await customersService.createCustomer(
            request: .init()
        )
        let customerToken = try await createCardCustomerToken(customerId: customer.id)
        let invoice = try await invoicesService.createInvoice(
            request: .init(name: UUID().uuidString, amount: 1, currency: "USD", customerId: customer.id)
        )
        let sut = createInteractor(
            configuration: .init(invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret))
        )

        // When
        await start(interactor: sut)

        // Then
        guard case .started(let startedState) = sut.state else {
            Issue.record("Interactor state is expected to be started.")
            return
        }
        #expect(startedState.paymentMethods.count == 1)
        #expect(startedState.paymentMethods.first?.customerTokenId == customerToken.id)
    }

    @Test
    func delete_whenPaymentMethodExists_deletesIt() async throws {
        // Given
        let customer = try await customersService.createCustomer(
            request: .init()
        )
        let customerToken = try await createCardCustomerToken(customerId: customer.id)
        let invoice = try await invoicesService.createInvoice(
            request: .init(name: UUID().uuidString, amount: 1, currency: "USD", customerId: customer.id)
        )
        let sut = createInteractor(
            configuration: .init(invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret))
        )
        await start(interactor: sut)

        // When
        sut.delete(customerTokenId: customerToken.id)

        // Then
        if case .removing(let currentState) = sut.state {
            #expect(currentState.removedCustomerTokenId == customerToken.id)
            _ = await currentState.task.result
        } else {
            Issue.record("Unexpected interactor state.")
        }
        if case .started(let currentState) = sut.state {
            #expect(currentState.paymentMethods.isEmpty)
        } else {
            Issue.record("Unexpected interactor state.")
        }
    }

    @Test
    func delete_whenAlreadyRemoving_queuesRemoval() async throws {
        // Given
        let customer = try await customersService.createCustomer(
            request: .init()
        )
        let customerTokens = [
            try await createCardCustomerToken(customerId: customer.id),
            try await createCardCustomerToken(customerId: customer.id)
        ]
        let invoice = try await invoicesService.createInvoice(
            request: .init(name: UUID().uuidString, amount: 1, currency: "USD", customerId: customer.id)
        )
        let sut = createInteractor(
            configuration: .init(invoiceRequest: .init(invoiceId: invoice.id, clientSecret: invoice.clientSecret))
        )
        await start(interactor: sut)

        // When
        sut.delete(customerTokenId: customerTokens[0].id)

        // Then
        sut.delete(customerTokenId: customerTokens[1].id)
        if case .removing(let currentState) = sut.state {
            _ = await currentState.task.result
            if case .removing(let currentState) = sut.state {
                _ = await currentState.task.result
            } else {
                Issue.record("Unexpected interactor state.")
            }
        }
        if case .started(let currentState) = sut.state {
            #expect(currentState.paymentMethods.isEmpty)
        } else {
            Issue.record("Unexpected interactor state.")
        }
    }

    @Test
    func cancel_whenStarting_completesWithFailure() async throws {
        // Given
        let sut = createInteractor(
            configuration: .init(invoiceRequest: .init(invoiceId: "", clientSecret: ""))
        )

        // When
        sut.start()

        // Then
        sut.cancel()
        if case .completed(let result) = sut.state {
            try withKnownIssue {
                _ = try result.get()
            } matching: { issue in
                if let failure = issue.error as? POFailure {
                    return failure.code == .cancelled
                }
                return false
            }
        } else {
            Issue.record("Interactor state is expected to be completed.")
        }
    }

    // MARK: - Private Properties

    private let cardsService: POCardsService
    private let invoicesService: POInvoicesService
    private let customersService: POCustomersService
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

    private func createCardCustomerToken(customerId: String) async throws -> POCustomerToken {
        let customerToken = try await customerTokensService.createCustomerToken(
            request: .init(customerId: customerId, verify: true)
        )
        let card = try await cardsService.tokenize(
            request: .init(number: "4000000000003055", expMonth: 12, expYear: 2040, cvc: "737")
        )
        let threeDSService = Stub3DS2Service(
            challengeResult: .init(transactionStatus: true),
            authenticationRequestParameters: .init(
                deviceData: "",
                sdkAppId: "",
                sdkEphemeralPublicKey: "",
                sdkReferenceNumber: "",
                sdkTransactionId: ""
            )
        )
        let updatedCustomerToken = try await customerTokensService.assignCustomerToken(
            request: .init(customerId: customerId, tokenId: customerToken.id, source: card.id, verify: true),
            threeDSService: threeDSService
        )
        return updatedCustomerToken
    }

    private func start(interactor: any SavedPaymentMethodsInteractor) async {
        switch interactor.state {
        case .idle:
            interactor.start()
            await start(interactor: interactor)
        case .starting(let currentState):
            _ = await currentState.task.result
            await start(interactor: interactor)
        case .started:
            return
        default:
            Issue.record("Unexpected state.")
        }
    }
}
