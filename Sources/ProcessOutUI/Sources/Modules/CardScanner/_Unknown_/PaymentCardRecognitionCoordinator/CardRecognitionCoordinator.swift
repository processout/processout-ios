//
//  CardRecognitionCoordinator.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

import AVFoundation
import Vision
@_spi(PO) import ProcessOut

/// - NOTE: Coordinator should be accessed from one thread at a time.
final class CardRecognitionCoordinator: CameraCoordinatorDelegate {

    init(
        numberDetector: some CardAttributeDetector<String>,
        expirationDetector: some CardAttributeDetector<String>,
        logger: POLogger
    ) {
        self.numberDetector = numberDetector
        self.expirationDetector = expirationDetector
        self.logger = logger
    }

    /// Preview view aspect ratio.
    @POUnfairlyLocked
    var previewAspectRatio: CGSize = .zero

    /// Preview view orientation.
    @POUnfairlyLocked
    var previewOrientation: CGImagePropertyOrientation = .up

    /// Coordinator delegate
    /// - NOTE: delegate methods are called on main thread.
    weak var delegate: CardRecognitionCoordinatorDelegate?

    func setCameraCoordinator(_ coordinator: CameraCoordinator) {
        coordinator.delegate = self
    }

    /// Starts card recognition.
    func start() {
        // NOP
    }

    /// Stops card recognition.
    func stop() {
        // NOP
    }

    // MARK: - CameraCoordinatorDelegate

    func cameraCoordinator(
        _ coordinator: CameraCoordinator, didOutput imageBuffer: CVImageBuffer, orientation: CGImagePropertyOrientation
    ) {
        let textRequest = createTextRecognitionRequest(
            regionOfIntereset: regionOfIntereset(imageBuffer: imageBuffer, orientation: orientation)
        )
        let handler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: orientation)
        do {
            try handler.perform([textRequest])
        } catch {
            logger.debug("Did fail to perform recognition request: \(error)")
            return
        }
        // todo(andrii-vysotskyi): consider detecting card rectangle to increase
        // chances that user scans actual card
        guard let card = scannedCard(in: textRequest.results) else {
            return
        }
        DispatchQueue.main.async { [weak self] in
            self?.delegate?.cardRecognitionCoordinator(self, didRecognizeCard: card)
        }
    }

    // MARK: - Private Properties

    private let numberDetector: any CardAttributeDetector<String>
    private let expirationDetector: any CardAttributeDetector<String>
    private let logger: POLogger

    // MARK: - Vision Requests

    private func createTextRecognitionRequest(regionOfIntereset: CGRect) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.regionOfInterest = regionOfIntereset
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        return request
    }

    private func regionOfIntereset(imageBuffer: CVImageBuffer, orientation: CGImagePropertyOrientation) -> CGRect {
        var bufferSize = CVImageBufferGetEncodedSize(imageBuffer)
        if orientation.isLandscape {
            // Video buffer orientation is locked to portrait, so size should be "rotated"
            // when actual orientation is landscape.
            swap(&bufferSize.width, &bufferSize.height)
        }
        var aspectRatio = previewAspectRatio
        if previewOrientation.isPortrait != orientation.isPortrait {
            // Aspect ratio should be "rotated" if preview orientation is perpendicular to buffer orientation.
            swap(&aspectRatio.width, &aspectRatio.height)
        }
        let scaledRect = AVMakeRect(
            aspectRatio: aspectRatio, insideRect: CGRect(origin: .zero, size: bufferSize)
        )
        return VNNormalizedRectForImageRect(scaledRect, Int(bufferSize.width), Int(bufferSize.height))
    }

    // MARK: - Card Attributes

    private func scannedCard(in observations: [VNRecognizedTextObservation]?) -> POScannedCard? {
        let candidates = observations?
            .compactMap { $0.topCandidates(1).first }
            .map(\.string)
        guard let candidates, !candidates.isEmpty,
              let number = numberDetector.firstMatch(in: candidates) else {
            return nil
        }
        let expiration = expirationDetector.firstMatch(in: candidates)
        // todo(andrii-vysotskyi): match cardholder name, possibly using Natural Language framework
        return POScannedCard(number: number, expiration: expiration, cardholder: nil)
    }
}
