//
//  CardsServiceTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 27.06.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

@MainActor final class CardsServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let configuration = ProcessOutConfiguration.production(projectId: Constants.projectId)
        sut = ProcessOut(configuration: configuration).cards
    }

    // MARK: - Tests

    func test_issuerInformation() async throws {
        // When
        let information = try await sut.issuerInformation(iin: "400012")

        // Then
        XCTAssertEqual(information.bankName, "BANK OF AMERICA NATIONAL ASSOCIATION")
        XCTAssertEqual(information.brand, "visa business")
        XCTAssertEqual(information.category, "commercial")
        XCTAssertEqual(information.scheme, "visa")
        XCTAssertEqual(information.type, "debit")
    }

    func test_tokenizeRequest_returnsCard() async throws {
        // Given
        let request = POCardTokenizationRequest(
            number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737"
        )

        // When
        let card = try await sut.tokenize(request: request)

        // Then
        XCTAssertEqual(card.last4Digits, "4242")
        XCTAssertEqual(card.expMonth, 12)
        XCTAssertEqual(card.expYear, 2040)
    }

    func test_issuerInformation_whenIinIsTooShort_throws() async {
        // Given
        let iin = "4"

        // When
        let issuerInformation = {
            try await self.sut.issuerInformation(iin: iin)
        }

        // Then
        await assertThrowsError(try await issuerInformation(), "IIN with length less than 6 symbols should be invalid")
    }

    func test_tokenizeRequest_whenNumberIsInvalid_throwsError() async {
        // Given
        let request = POCardTokenizationRequest(number: "", expMonth: 12, expYear: 40, cvc: "737")

        // When
        let card = {
            try await self.sut.tokenize(request: request)
        }

        // Then
        await assertThrowsError(try await card(), "Unexpected success, card number is invalid")
    }

    func test_updateCard() async throws {
        // Given
        let card = try await sut.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )
        let cardUpdateRequest = POCardUpdateRequest(cardId: card.id, cvc: "123")

        // When
        _ = try await sut.updateCard(request: cardUpdateRequest)
    }

    func test_tokenize_whenPreferredSchemeIsSet() async throws {
        // Given
        let request = POCardTokenizationRequest(
            number: "5341026607460971", expMonth: 12, expYear: 40, preferredScheme: "carte bancaire"
        )

        // When
        let card = try await sut.tokenize(request: request)

        // Then
        XCTAssertEqual(card.preferredScheme, request.preferredScheme)
    }

    // MARK: - Private Properties

    private var sut: POCardsService!
}
