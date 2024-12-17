//
//  CardRecognitionCoordinator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.11.2024.
//

import AVFoundation
import Vision
import UIKit
@_spi(PO) import ProcessOut

actor CardRecognitionSession: CameraSessionDelegate {

    init(
        numberDetector: some CardAttributeDetector<String>,
        expirationDetector: some CardAttributeDetector<POScannedCard.Expiration>,
        cardholderNameDetector: some CardAttributeDetector<String>,
        errorCorrection: CardRecognitionSessionErrorCorrection,
        logger: POLogger
    ) {
        self.numberDetector = numberDetector
        self.expirationDetector = expirationDetector
        self.cardholderNameDetector = cardholderNameDetector
        self.errorCorrection = errorCorrection
        self.logger = logger
    }

    /// Starts recognition session using giving camera session as a source.
    func setCameraSession(_ cameraSession: CameraSession) async {
        await self.cameraSession?.setDelegate(nil)
        await cameraSession.setDelegate(self)
        self.cameraSession = cameraSession
    }

    func setDelegate(_ delegate: CardRecognitionSessionDelegate?) {
        self.delegate = delegate
    }

    // MARK: - CameraSessionDelegate

    func cameraSession(_ session: CameraSession, didOutput image: CIImage) async {
        let textRequest = createTextRecognitionRequest()
        let shapeRequest = createCardShapeRecognitionRequest()
        do {
            let handler = VNImageRequestHandler(ciImage: image)
            try handler.perform([textRequest, shapeRequest])
        } catch {
            logger.debug("Failed to perform recognition request: \(error).")
            await process(scannedCard: nil)
            return
        }
        let recognizedTexts = recognizedTexts(for: textRequest.results, inside: shapeRequest.results?.first)
        await process(scannedCard: scannedCard(in: recognizedTexts))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minimumConfidence: VNConfidence = 0.8
    }

    // MARK: - Private Properties

    private let logger: POLogger

    private var cameraSession: CameraSession?
    private weak var delegate: CardRecognitionSessionDelegate?

    // MARK: - Vision

    private func createTextRecognitionRequest() -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        return request
    }

    private func createCardShapeRecognitionRequest() -> VNDetectRectanglesRequest {
        let request = VNDetectRectanglesRequest()
        request.maximumObservations = 1
        let idealAspectRatio: VNAspectRatio = 0.631 // ISO/IEC 7810 based ± 10%
        request.minimumAspectRatio = idealAspectRatio * 0.9
        request.maximumAspectRatio = idealAspectRatio * 1.1
        request.minimumSize = 0.25
        request.minimumConfidence = Constants.minimumConfidence
        return request
    }

    private func recognizedTexts(
        for textObservations: [VNRecognizedTextObservation]?, inside rectangleObservation: VNRectangleObservation?
    ) -> [VNRecognizedText] {
        guard let rectangleObservation else {
            return [] // Abort recognition if card shape is not detected
        }
        let candidates = textObservations?
            .filter { textObservation in
                shouldInclude(textObservation: textObservation, cardRectangleObservation: rectangleObservation)
            }
            .sorted { lhs, rhs in
                // Sort observations bottom-to-top as cardholder names are often in the lower half of the card.
                lhs.boundingBox.minY < rhs.boundingBox.minY
            }
            .compactMap { textObservation in
                textObservation.topCandidates(1).first
            }
        return candidates ?? []
    }

    private func shouldInclude(
        textObservation: VNRecognizedTextObservation, cardRectangleObservation: VNRectangleObservation
    ) -> Bool {
        guard textObservation.confidence > Constants.minimumConfidence else {
            return false
        }
        return textObservation.boundingBox.intersects(cardRectangleObservation.boundingBox)
    }

    // MARK: - Card Attributes

    private let numberDetector: any CardAttributeDetector<String>
    private let expirationDetector: any CardAttributeDetector<POScannedCard.Expiration>
    private let cardholderNameDetector: any CardAttributeDetector<String>

    private func scannedCard(in recognizedTexts: [VNRecognizedText]) -> POScannedCard? {
        var candidates = recognizedTexts.compactMap { $0.string }
        guard let number = numberDetector.firstMatch(in: &candidates) else {
            return nil
        }
        let expiration = expirationDetector.firstMatch(in: &candidates)
        let cardholderName = cardholderNameDetector.firstMatch(in: &candidates)
        return POScannedCard(number: number, expiration: expiration, cardholderName: cardholderName)
    }

    // MARK: - Scanned Card Processing

    private let errorCorrection: CardRecognitionSessionErrorCorrection
    private var lastErrorCorrectedCard: POScannedCard?

    private func process(scannedCard: POScannedCard?) async {
        guard let errorCorrectedCard = errorCorrection.add(scannedCard: scannedCard) else {
            return
        }
        if errorCorrectedCard != lastErrorCorrectedCard {
            lastErrorCorrectedCard = errorCorrectedCard
            await delegate?.cardRecognitionSession(self, didUpdateCard: errorCorrectedCard)
        }
        if errorCorrection.isConfident {
            await delegate?.cardRecognitionSession(self, didRecognizeCard: errorCorrectedCard)
        }
    }
}
