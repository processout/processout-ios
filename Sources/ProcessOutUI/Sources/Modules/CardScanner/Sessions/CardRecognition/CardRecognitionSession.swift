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
            logger.debug("Failed to perform recognition request: \(error).")
            return
        }
        let recognizedTexts = self.recognizedTexts(for: textRequest.results, inside: shapeRequest.results?.first)
        if let card = scannedCard(in: recognizedTexts) {
            logger.debug("Did recognize card details: \(card).")
            await delegate?.cardRecognitionSession(self, didRecognize: card)
        }
    }

    // MARK: - Private Properties

    private let numberDetector: any CardAttributeDetector<String>
    private let expirationDetector: any CardAttributeDetector<POScannedCard.Expiration>
    private let cardholderNameDetector: any CardAttributeDetector<String>
    private let logger: POLogger

    private var cameraSession: CameraSession?

    /// Delegate.
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
        request.minimumAspectRatio = 1.586 * 0.9 // ISO/IEC 7810 based ± 10%
        request.maximumAspectRatio = 1.586 * 1.1
        request.minimumSize = 0.8
        request.minimumConfidence = 0.8
        return request
    }

    private func recognizedTexts(
        for textObservation: [VNRecognizedTextObservation]?, inside rectangleObservation: VNRectangleObservation?
    ) -> [VNRecognizedText] {
        guard rectangleObservation != nil else {
            return [] // Abort recognition if card shape is not detected
        }
        let candidates = textObservation?
            .compactMap { observation in
                observation.topCandidates(1).first
            }
        return candidates ?? []
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
}
