//
//  CardRecognitionSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

/// A delegate protocol for monitoring the progress and results of a card recognition session.
protocol CardRecognitionSessionDelegate: AnyObject, Sendable {

    /// Called when the session updates currently recognized card info.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didUpdateCard card: POScannedCard)

    /// Called when the session successfully recognizes a card.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard)
}
