//
//  CardRecognitionSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

/// A delegate protocol for monitoring the progress and results of a card recognition session.
protocol CardRecognitionSessionDelegate: AnyObject, Sendable {

    /// Called when the session begins validating a detected card.
    ///
    /// This is typically triggered during the temporal stability check,
    /// where the session ensures that the card is consistently detected
    /// in multiple video frames.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, willValidateCard card: POScannedCard)

    /// Called when the session successfully recognizes a card.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard)

    /// Called when the session fails to validate a detected card.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didFailToValidateCard card: POScannedCard)
}
