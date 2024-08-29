//
//  CustomerTokensServiceTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.07.2023.
//

import XCTest
@testable @_spi(PO) import ProcessOut

final class CustomerTokensServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let configuration = ProcessOutConfiguration(
            projectId: Constants.projectId, privateKey: Constants.projectPrivateKey
        )
        ProcessOut.configure(configuration: configuration, force: true)
        sut = ProcessOut.shared.customerTokens
        cardsService = ProcessOut.shared.cards
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
        let request = POAssignCustomerTokenRequest(
            customerId: Constants.customerId,
            tokenId: try await createToken(verify: false).id,
            source: card.id
        )

        // When
        let updatedToken = try await sut.assignCustomerToken(request: request, threeDSService: Mock3DSService())

        // Then
        XCTAssertEqual(updatedToken.cardId, card.id)
    }

    func test_assignCustomerToken_whenVerifyIsSetToTrue_triggers3DS() async throws {
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
        let threeDSService = Mock3DSService()
        threeDSService.authenticationRequestFromClosure = { _, completion in
            completion(.failure(.init(code: .cancelled)))
        }

        // When
        _ = try? await sut.assignCustomerToken(request: request, threeDSService: threeDSService)

        // Then
        XCTAssertEqual(threeDSService.authenticationRequestCallsCount, 1)
    }

    // MARK: - Private Properties

    private var sut: POCustomerTokensService!
    private var cardsService: POCardsService!

    // MARK: - Private Methods

    private func createToken(verify: Bool) async throws -> POCustomerToken {
        let request = POCreateCustomerTokenRequest(customerId: Constants.customerId, verify: verify)
        return try await sut.createCustomerToken(request: request)
    }
}
