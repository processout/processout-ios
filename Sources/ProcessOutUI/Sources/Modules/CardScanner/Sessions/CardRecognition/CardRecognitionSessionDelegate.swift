//
//  CardRecognitionSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

import AVFoundation

/// A delegate protocol for monitoring the progress and results of a card recognition session.
protocol CardRecognitionSessionDelegate: AnyObject, Sendable {

    /// Called when the session updates currently recognized card info.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didUpdateCard card: POScannedCard?)

    /// Called when the session successfully recognizes a card.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard)

    /// Implementation could return region of interest inside rect for card recognition.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, regionOfInterestInside rect: CGRect) -> CGRect?
}
