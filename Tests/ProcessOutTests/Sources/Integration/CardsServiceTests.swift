//
//  CardsServiceTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 27.06.2023.
//

import Foundation
import XCTest
@testable import ProcessOut

final class CardsServiceTests: XCTestCase {

    override func setUp() {
        super.setUp()
        ProcessOut.configure(configuration: .production(projectId: Constants.projectId), force: true)
        sut = ProcessOut.shared.cards
    }

    // MARK: - Tests

    func test_issuerInformation() async throws {
        // When
        let information = try await sut.issuerInformation(iin: "400012")

        // Then
        XCTAssertEqual(information.bankName, "UNITED CITIZENS BANK OF SOUTHERN KENTUCKY")
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

    func test_updateCard_whenCvcIsSet_updatesIt() async throws {
        // Given
        let card = try await sut.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )

        // When
        let updatedCard = try await sut.updateCard(
            request: POCardUpdateRequest(cardId: card.id, cvc: "123")
        )

        // Then
        XCTAssertEqual(updatedCard.updateType, "new-cvc2")
    }

    func test_updateCard_whenPreferredSchemeIsSet_updatesIt() async throws {
        // Given
        let card = try await sut.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )

        // When
        let updatedCard = try await sut.updateCard(
            request: POCardUpdateRequest(cardId: card.id, preferredScheme: "test")
        )

        // Then
        XCTAssertEqual(updatedCard.preferredScheme, "test")
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
