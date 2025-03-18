//
//  CardRecognitionSessionErrorCorrectionTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

import Testing
@_spi(PO) import ProcessOut
@testable import ProcessOutUI

struct CardRecognitionSessionErrorCorrectionTests {

    @Test
    func add_whenScannedCardIsNonNil_returnsCorrectedCard() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()

        // When
        let scannedCard = POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        let correctedCard = sut.add(scannedCard: scannedCard)

        // Then
        #expect(correctedCard == scannedCard)
    }

    @Test
    func add_whenErrorCorrectionDurationIsReached_changesConfidence() async {
        // Given
        let sut = CardRecognitionSessionErrorCorrection(errorCorrectionDuration: 0.5)

        // When
        _ = sut.add(
            scannedCard: POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        )
        try? await Task.sleep(seconds: 1)

        // Then
        #expect(sut.isConfident)
    }

    @Test
    func add_whenErrorCorrectionDurationIsNotReached_doesntChangeConfidence() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection(errorCorrectionDuration: 0.5)

        // When
        _ = sut.add(
            scannedCard: POScannedCard(number: "1", expiration: nil, cardholderName: nil)
        )

        // Then
        #expect(!sut.isConfident)
    }

    @Test
    func add_returnsMostFrequentNumber() {
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
        #expect(recentCorrectedCard?.number == "2")
    }

    @Test
    func add_returnsMostFrequentExpiration() {
        // Given
        let sut = CardRecognitionSessionErrorCorrection()
        var recentCorrectedCard: POScannedCard?

        // When
        let cards: [POScannedCard] = [
            .init(
                number: "",
                expiration: .init(month: 1, year: 1, isExpired: false, description: ""),
                cardholderName: nil
            ),
            .init(
                number: "",
                expiration: .init(month: 2, year: 3, isExpired: false, description: ""),
                cardholderName: nil
            ),
            .init(
                number: "",
                expiration: .init(month: 2, year: 3, isExpired: false, description: ""),
                cardholderName: nil
            )
        ]
        for card in cards {
            recentCorrectedCard = sut.add(scannedCard: card)
        }

        // Then
        #expect(recentCorrectedCard?.expiration == .init(month: 2, year: 3, isExpired: false, description: ""))
    }

    @Test
    func add_returnsMostFrequentCardholder() {
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
        #expect(recentCorrectedCard?.cardholderName == "2")
    }
}
