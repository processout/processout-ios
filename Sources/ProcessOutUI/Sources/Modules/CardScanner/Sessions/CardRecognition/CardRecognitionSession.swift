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
        logger: POLogger
    ) {
        self.numberDetector = numberDetector
        self.expirationDetector = expirationDetector
        self.cardholderNameDetector = cardholderNameDetector
        self.logger = logger
    }

    /// Starts recognition session using giving camera session as a source.
    func setCameraSession(_ cameraSession: CameraSession) async -> Bool {
        await cameraSession.setDelegate(self)
        self.cameraSession = cameraSession
        return true
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
            await abortScannedCardValidation()
            logger.debug("Failed to perform recognition request: \(error).")
            return
        }
        let recognizedTexts = self.recognizedTexts(for: textRequest.results, inside: shapeRequest.results?.first)
        if let card = scannedCard(in: recognizedTexts) {
            await validate(scannedCard: card)
        } else {
            await abortScannedCardValidation()
        }
    }

    // MARK: - Private Properties

    private let numberDetector: any CardAttributeDetector<String>
    private let expirationDetector: any CardAttributeDetector<POScannedCard.Expiration>
    private let cardholderNameDetector: any CardAttributeDetector<String>
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
        request.minimumSize = 0.7
        request.minimumConfidence = 0.8
        return request
    }

    private func recognizedTexts(
        for textObservation: [VNRecognizedTextObservation]?, inside rectangleObservation: VNRectangleObservation?
    ) -> [VNRecognizedText] {
        guard let rectangleObservation else {
            return [] // Abort recognition if card shape is not detected
        }
        let candidates = textObservation?
            .filter { textObservation in
                shouldInclude(textObservation: textObservation, cardRectangleObservation: rectangleObservation)
            }
            .compactMap { observation in
                observation.topCandidates(1).first
            }
        return candidates ?? []
    }

    private func shouldInclude(
        textObservation: VNRecognizedTextObservation, cardRectangleObservation: VNRectangleObservation
    ) -> Bool {
        let boundingBoxInsetMultiplier = -1.15 // Expands bounding box by 15% of its size
        let textObservationBox = textObservation.boundingBox.insetBy(
            dx: textObservation.boundingBox.size.width * boundingBoxInsetMultiplier,
            dy: textObservation.boundingBox.size.height * boundingBoxInsetMultiplier
        )
        let cardObservationBox = cardRectangleObservation.boundingBox.insetBy(
            dx: cardRectangleObservation.boundingBox.width * boundingBoxInsetMultiplier,
            dy: cardRectangleObservation.boundingBox.height * boundingBoxInsetMultiplier
        )
        return textObservationBox.intersects(cardObservationBox)
    }

    // MARK: - Card Attributes

    private func scannedCard(in recognizedTexts: [VNRecognizedText]) -> POScannedCard? {
        var candidates = recognizedTexts.compactMap { $0.string }
        guard let number = numberDetector.firstMatch(in: &candidates) else {
            return nil
        }
        let expiration = expirationDetector.firstMatch(in: &candidates)
        let cardholderName = cardholderNameDetector.firstMatch(in: &candidates)
        return POScannedCard(number: number, expiration: expiration, cardholderName: cardholderName)
    }

    // MARK: - Validation

    private var cardValidationTask: Task<Void, Never>?
    private var activeScannedCard: POScannedCard?

    private func validate(scannedCard: POScannedCard) async {
        if scannedCard != activeScannedCard {
            await abortScannedCardValidation()
        }
        guard cardValidationTask == nil else {
            return
        }
        cardValidationTask = Task {
            try? await Task.sleep(seconds: 2)
            guard !Task.isCancelled else {
                return
            }
            logger.debug("Did recognize card: \(scannedCard).")
            activeScannedCard = nil
            await delegate?.cardRecognitionSession(self, didRecognizeCard: scannedCard)
        }
        logger.debug("Will validate scanned card: \(scannedCard).")
        activeScannedCard = scannedCard
        await delegate?.cardRecognitionSession(self, willValidateCard: scannedCard)
    }

    private func abortScannedCardValidation() async {
        if let task = cardValidationTask {
            task.cancel()
            cardValidationTask = nil
        }
        guard let card = activeScannedCard else {
            return
        }
        logger.debug("Card validation was interrupted: \(card).")
        activeScannedCard = nil
        await delegate?.cardRecognitionSession(self, didFailToValidateCard: card)
    }
}
