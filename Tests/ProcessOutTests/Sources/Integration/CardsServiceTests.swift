//
//  CardsServiceTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 27.06.2023.
//

import Foundation
import Testing
@testable import ProcessOut

struct CardsServiceTests {

    init() async {
        let processOut = await ProcessOut(configuration: .init(projectId: Constants.projectId))
        sut = processOut.cards
    }

    // MARK: - Tests

    @Test
    func issuerInformation() async throws {
        // When
        let information = try await sut.issuerInformation(iin: "400012")

        // Then
        #expect(information.bankName == "UNITED CITIZENS BANK OF SOUTHERN KENTUCKY")
        #expect(information.brand == "visa business")
        #expect(information.category == "commercial")
        #expect(information.$scheme.typed == .visa)
        #expect(information.type == "debit")
    }

    @Test
    func tokenizeRequest_returnsCard() async throws {
        // Given
        let request = POCardTokenizationRequest(
            number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737"
        )

        // When
        let card = try await sut.tokenize(request: request)

        // Then
        #expect(card.last4Digits == "4242" && card.expMonth == 12 && card.expYear == 2040)
    }

    @Test
    func issuerInformation_whenIinIsTooShort_throws() async {
        // Given
        let iin = "4"

        // When
        await withKnownIssue {
            _ = try await self.sut.issuerInformation(iin: iin)
        }
    }

    @Test
    func tokenizeRequest_whenNumberIsInvalid_throwsError() async {
        // Given
        let request = POCardTokenizationRequest(number: "", expMonth: 12, expYear: 40, cvc: "737")

        // When
        await withKnownIssue {
            _ = try await self.sut.tokenize(request: request)
        }
    }

    @Test
    func updateCard_whenCvcIsSet_updatesIt() async throws {
        // Given
        let card = try await sut.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )

        // When
        let updatedCard = try await sut.updateCard(
            request: POCardUpdateRequest(cardId: card.id, cvc: "123")
        )

        // Then
        #expect(updatedCard.updateType == "new-cvc2")
    }

    @Test
    func updateCard_whenPreferredSchemeIsSet_updatesIt() async throws {
        // Given
        let card = try await sut.tokenize(
            request: .init(number: "4242424242424242", expMonth: 12, expYear: 40, cvc: "737")
        )

        // When
        let updatedCard = try await sut.updateCard(
            request: POCardUpdateRequest(cardId: card.id, preferredScheme: "test")
        )

        // Then
        #expect(updatedCard.$preferredScheme.typed == "test")
    }

    @Test
    func tokenize_whenPreferredSchemeIsSet() async throws {
        // Given
        let request = POCardTokenizationRequest(
            number: "5341026607460971", expMonth: 12, expYear: 40, preferredScheme: "carte bancaire"
        )

        // When
        let card = try await sut.tokenize(request: request)

        // Then
        #expect(card.preferredScheme == request.preferredScheme)
    }

    // MARK: - Private Properties

    private let sut: POCardsService
}
