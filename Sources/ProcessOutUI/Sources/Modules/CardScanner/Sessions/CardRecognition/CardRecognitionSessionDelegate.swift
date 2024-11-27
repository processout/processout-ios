//
//  CardRecognitionSessionDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

protocol CardRecognitionSessionDelegate: AnyObject, Sendable {

    /// Notifies delegate of recognized card.
    @MainActor
    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognize card: POScannedCard)

    /// Notifies delegate of recognized card.
    @MainActor
    func cardRecognitionSessionDidFailToRecognizeCard(_ session: CardRecognitionSession)
}
