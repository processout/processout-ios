//
//  MockCardRecognitionSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.12.2024.
//

@testable @_spi(PO) import ProcessOutUI

@MainActor
final class MockCardRecognitionSessionDelegate: CardRecognitionSessionDelegate {

    nonisolated init() {
        // Ignored
    }

    // MARK: - CardRecognitionSessionDelegate

    func cardRecognitionSession(_ session: CardRecognitionSession, didUpdateCard card: POScannedCard) {
        didUpdateCardCallsCount += 1
        lastUpdatedCard = card
    }

    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard) {
        didRecognizeCardCallsCount += 1
        lastRecognizedCard = card
    }

    // MARK: -

    /// Number of times `cardRecognitionSession(_:didUpdateCard:)` has been called.
    private(set) var didUpdateCardCallsCount = 0

    /// Most recently updated card.
    private(set) var lastUpdatedCard: POScannedCard?

    /// Number of times `cardRecognitionSession(_:didRecognizeCard:)` has been called.
    private(set) var didRecognizeCardCallsCount = 0

    /// Most recently recognized card.
    private(set) var lastRecognizedCard: POScannedCard?
}
