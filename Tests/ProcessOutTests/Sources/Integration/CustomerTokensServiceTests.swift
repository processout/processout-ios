//
//  CustomerTokensServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.07.2023.
//

import XCTest
@_spi(PO) @testable import ProcessOut

@MainActor final class CustomerTokensServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let configuration = ProcessOutConfiguration.production(
            projectId: Constants.projectId, privateKey: Constants.projectPrivateKey
        )
        let processOut = ProcessOut(configuration: configuration)
        sut = processOut.customerTokens
        cardsService = processOut.cards
    }

    // MARK: - Tests

    func test_createCustomerToken_returnsToken() async throws {
        // Given
        let request = POCreateCustomerTokenRequest(customerId: Constants.customerId)

        // When
        let token = try await sut.createCustomerToken(request: request)

        // Then
        XCTAssertEqual(token.customerId, request.customerId)
    }

    func test_assignCustomerToken_whenVerifyIsSetToFalse_assignsNewSource() async throws {
        // Given
        let card = try await cardsService.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )
        let token = try await sut.createCustomerToken(
            request: POCreateCustomerTokenRequest(customerId: Constants.customerId)
        )
        let request = POAssignCustomerTokenRequest(
            customerId: Constants.customerId, tokenId: token.id, source: card.id, verify: false
        )

        // When
        let updatedToken = try await sut.assignCustomerToken(request: request, threeDSService: Mock3DSService())

        // Then
        XCTAssertEqual(updatedToken.cardId, card.id)
    }

    // MARK: - Private Properties

    private var sut: POCustomerTokensService!
    private var cardsService: POCardsService!
}
