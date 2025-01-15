//
//  CustomerTokensServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.07.2023.
//

import Foundation
import os
import Testing
@testable @_spi(PO) import ProcessOut

struct CustomerTokensServiceTests {

    init() async {
        let processOut = await ProcessOut(
            configuration: .init(projectId: Constants.projectId, privateKey: Constants.projectPrivateKey)
        )
        sut = processOut.customerTokens
        cardsService = processOut.cards
        invoicesService = processOut.invoices
        eventEmitter = processOut.eventEmitter
    }

    // MARK: - Tests

    @Test
    func createCustomerToken_returnsToken() async throws {
        // Given
        let request = POCreateCustomerTokenRequest(customerId: Constants.customerId)

        // When
        let token = try await sut.createCustomerToken(request: request)

        // Then
        #expect(token.customerId == request.customerId)
    }

    @Test
    func assignCustomerToken_whenVerifyIsSetToFalse_assignsNewSource() async throws {
        // Given
        let card = try await cardsService.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )
        let request = POAssignCustomerTokenRequest(
            customerId: Constants.customerId,
            tokenId: try await createToken(verify: false).id,
            source: card.id
        )

        // When
        let updatedToken = try await sut.assignCustomerToken(request: request, threeDSService: Mock3DS2Service())

        // Then
        #expect(updatedToken.cardId == card.id)
    }

    @Test
    func assignCustomerToken_whenVerifyIsSetToTrue_triggers3DS() async throws {
        // Given
        let card = try await cardsService.tokenize(
            request: .init(number: "4000000000000101", expMonth: 12, expYear: 40, cvc: "737")
        )
        let request = POAssignCustomerTokenRequest(
            customerId: Constants.customerId,
            tokenId: try await createToken(verify: true).id,
            source: card.id,
            verify: true,
            enableThreeDS2: true
        )
        let threeDSService = Mock3DS2Service()
        threeDSService.authenticationRequestParametersFromClosure = { _ in
            throw POFailure(code: .cancelled)
        }

        // When
        _ = try? await sut.assignCustomerToken(request: request, threeDSService: threeDSService)

        // Then
        #expect(threeDSService.authenticationRequestParametersCallsCount == 1)
    }

    @Test
    func deleteCustomerToken_sendsEvent() async throws {
        // Given
        let invoice = try await invoicesService.createInvoice(
            request: .init(name: UUID().uuidString, amount: 1, currency: "USD", customerId: Constants.customerId)
        )
        let token = try await createToken(verify: false)
        let didReceiveEvent = OSAllocatedUnfairLock(uncheckedState: false)

        // When
        let eventSubscription = eventEmitter.on(POCustomerTokenDeletedEvent.self) { event in
            #expect(event.customerId == Constants.customerId)
            #expect(event.tokenId == token.id)
            didReceiveEvent.withLock { $0 = true }
            return true
        }
        let request = PODeleteCustomerTokenRequest(
            customerId: token.customerId,
            tokenId: token.id,
            clientSecret: invoice.clientSecret ?? ""
        )
        try await sut.deleteCustomerToken(request: request)

        // Then
        didReceiveEvent.withLock { #expect($0 == true) }
        _ = eventSubscription
    }

    // MARK: - Private Properties

    private let sut: POCustomerTokensService
    private let cardsService: POCardsService
    private let invoicesService: POInvoicesService
    private let eventEmitter: POEventEmitter

    // MARK: - Private Methods

    private func createToken(verify: Bool) async throws -> POCustomerToken {
        let request = POCreateCustomerTokenRequest(customerId: Constants.customerId, verify: verify)
        return try await sut.createCustomerToken(request: request)
    }
}
