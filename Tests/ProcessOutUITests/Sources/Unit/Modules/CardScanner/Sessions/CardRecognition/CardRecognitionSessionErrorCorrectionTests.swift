//
//  CardRecognitionSessionErrorCorrectionTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

import XCTest
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

final class CardRecognitionSessionErrorCorrectionTests: XCTestCase {

    func test_add_whenScannedCardIsNonNil_returnsCorrectedCard() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()

        // When
        let scannedCard = POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        let correctedCard = sut.add(scannedCard: scannedCard)

        // Then
        XCTAssertEqual(correctedCard, scannedCard)
    }

    func test_add_whenErrorCorrectionDurationIsReached_changesConfidence() async {
        // Given
        let sut = CardRecognitionSessionErrorCorrection(errorCorrectionDuration: 0.5)

        // When
        _ = sut.add(
            scannedCard: POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        )
        try? await Task.sleep(seconds: 1)

        // Then
        XCTAssertTrue(sut.isConfident)
    }

    func test_add_whenErrorCorrectionDurationIsNotReached_doesntChangeConfidence() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection(errorCorrectionDuration: 0.5)

        // When
        _ = sut.add(
            scannedCard: POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        )

        // Then
        XCTAssertFalse(sut.isConfident)
    }

    func test_add_returnsMostFrequentNumber() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()
        var recentCorrectedCard: POScannedCard?

        // When
        let cards: [POScannedCard] = [
            .init(number: "1", expiration: nil, cardholderName: nil),
            .init(number: "2", expiration: nil, cardholderName: nil),
            .init(number: "2", expiration: nil, cardholderName: nil)
        ]
        for card in cards {
            recentCorrectedCard = sut.add(scannedCard: card)
        }

        // Then
        XCTAssertEqual(recentCorrectedCard?.number, "2")
    }

    func test_add_returnsMostFrequentExpiration() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()
        var recentCorrectedCard: POScannedCard?

        // When
        let cards: [POScannedCard] = [
            .init(number: "", expiration: .init(month: 1, year: 1, description: ""), cardholderName: nil),
            .init(number: "", expiration: .init(month: 2, year: 3, description: ""), cardholderName: nil),
            .init(number: "", expiration: .init(month: 2, year: 3, description: ""), cardholderName: nil)
        ]
        for card in cards {
            recentCorrectedCard = sut.add(scannedCard: card)
        }

        // Then
        XCTAssertTrue(recentCorrectedCard?.expiration == .init(month: 2, year: 3, description: ""))
    }

    func test_add_returnsMostFrequentCardholder() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()
        var recentCorrectedCard: POScannedCard?

        // When
        let cards: [POScannedCard] = [
            .init(number: "", expiration: nil, cardholderName: "1"),
            .init(number: "", expiration: nil, cardholderName: "2"),
            .init(number: "", expiration: nil, cardholderName: "2")
        ]
        for card in cards {
            recentCorrectedCard = sut.add(scannedCard: card)
        }

        // Then
        XCTAssertTrue(recentCorrectedCard?.cardholderName == "2")
    }
}
