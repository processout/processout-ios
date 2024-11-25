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

actor CardRecognitionSession: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {

    init(
        numberDetector: some CardAttributeDetector<String>,
        expirationDetector: some CardAttributeDetector<String>,
        logger: POLogger
    ) {
        self.numberDetector = numberDetector
        self.expirationDetector = expirationDetector
        self.logger = logger
        super.init()
    }

    /// Starts recognition session using giving camera session as a source.
    func setCameraSession(_ cameraSession: CameraSession) async -> Bool {
        await stop()
        let videoOutput = createVideoOutput()
        guard await cameraSession.addOutput(videoOutput) else {
            return false
        }
        self.videoDataOutput = videoOutput
        self.cameraSession = cameraSession
        return true
    }

    func setDelegate(_ delegate: CardRecognitionSessionDelegate?) {
        self.delegate = delegate
    }

    /// Invalidates recognition session effectively stopping recognition.
    func stop() async {
        if let cameraSession, let videoDataOutput {
            await cameraSession.removeOutput(videoDataOutput)
        }
        cameraSession = nil
        videoDataOutput = nil
    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

    nonisolated func captureOutput(
        _ output: AVCaptureOutput,
        didOutput sampleBuffer: CMSampleBuffer,
        from connection: AVCaptureConnection
    ) {
        guard !shouldDiscardVideoFrames.wrappedValue,
              let imageBuffer = sampleBuffer.imageBuffer else {
            return
        }
        let image = CIImage(cvImageBuffer: imageBuffer)
        Task {
            await self.performRecognition(on: image, with: connection.videoOrientation)
            shouldDiscardVideoFrames.withLock { $0 = false }
        }
        shouldDiscardVideoFrames.withLock { $0 = true }
    }

    // MARK: - Private Properties

    private let numberDetector: any CardAttributeDetector<String>
    private let expirationDetector: any CardAttributeDetector<String>
    private let logger: POLogger

    private var cameraSession: CameraSession?
    private var videoDataOutput: AVCaptureVideoDataOutput?

    /// Boolean value indicating whether new video frames should be discarded.
    private nonisolated(unsafe) var shouldDiscardVideoFrames = POUnfairlyLocked(wrappedValue: false)

    /// Delegate.
    private weak var delegate: CardRecognitionSessionDelegate?

    // MARK: - Video Output

    private func createVideoOutput() -> AVCaptureVideoDataOutput {
        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
        ]
        let queue = DispatchQueue(label: "processout.card-recognition-session", qos: .userInitiated)
        output.setSampleBufferDelegate(self, queue: queue)
        return output
    }

    // MARK: - Vision

    private func performRecognition(on image: CIImage, with videoOrientation: AVCaptureVideoOrientation) async {
        let correctedImage = await self.corrected(
            image: image, videoOrientation: videoOrientation
        )
        let regionOfInterest = await self.regionOfInterest(inside: correctedImage)
        let textRequest = createTextRecognitionRequest(regionOfInterest: regionOfInterest)
        let shapeRequest = createCardShapeRecognitionRequest(regionOfInterest: regionOfInterest)
        do {
            let handler = VNImageRequestHandler(ciImage: correctedImage)
            try handler.perform([textRequest, shapeRequest])
        } catch {
            logger.debug("Failed to perform recognition request: \(error).")
            return
        }
        guard !(shapeRequest.results?.isEmpty ?? true), let card = scannedCard(in: textRequest.results) else {
            return
        }
        logger.debug("Did recognize card details: \(card).")
        await delegate?.cardRecognitionSession(self, didRecognize: card)
    }

    private func createTextRecognitionRequest(regionOfInterest: CGRect) -> VNRecognizeTextRequest {
        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = false
        request.recognitionLanguages = ["en-US"]
        request.regionOfInterest = regionOfInterest
        return request
    }

    private func createCardShapeRecognitionRequest(regionOfInterest: CGRect) -> VNDetectRectanglesRequest {
        let request = VNDetectRectanglesRequest()
        request.maximumObservations = 1
        request.minimumAspectRatio = 1.586 * 0.9 // ISO/IEC 7810 based ± 10%
        request.maximumAspectRatio = 1.586 * 1.1
        request.minimumSize = 0.5
        request.minimumConfidence = 0.5
        request.regionOfInterest = regionOfInterest
        return request
    }

    private func regionOfInterest(inside image: CIImage) async -> CGRect {
        if let aspectRatio = await videoPreviewLayer?.owningView?.bounds.size {
            let scaledRect = AVMakeRect(
                aspectRatio: aspectRatio, insideRect: image.extent
            )
            return VNNormalizedRectForImageRect(scaledRect, Int(image.extent.width), Int(image.extent.height))
        } else {
            return CGRect(x: 0, y: 0, width: 1, height: 1)
        }
    }

    // MARK: - Image Correction

    private func corrected(image: CIImage, videoOrientation: AVCaptureVideoOrientation) async -> CIImage {
        let rotatedImage = image.transformed(
            by: .init(rotationAngle: await videoRotationAngle(for: videoOrientation))
        )
        let translatedImage = rotatedImage.transformed(
            by: .init(translationX: -rotatedImage.extent.origin.x, y: -rotatedImage.extent.origin.y)
        )
        return translatedImage
    }

    /// Returns rotation angle in radians.
    private func videoRotationAngle(for videoOrientation: AVCaptureVideoOrientation) async -> CGFloat {
        var angle: CGFloat
        switch videoOrientation {
        case .landscapeLeft:
            angle = 90
        case .portraitUpsideDown:
            angle = 180
        case .landscapeRight:
            angle = 270
        default:
            angle = 0
        }
        switch await videoPreviewLayer?.owningView?.window?.windowScene?.interfaceOrientation {
        case .landscapeRight:
            angle += 90
        case .portraitUpsideDown:
            angle += 180
        case .landscapeLeft:
            angle += 270
        default:
            angle += 0
        }
        return (angle / 180).truncatingRemainder(dividingBy: 360) * .pi
    }

    // MARK: - Preview Layer

    private var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        get async {
            guard let captureSession = await cameraSession?.captureSession else {
                return nil
            }
            for connection in captureSession.connections {
                if let layer = connection.videoPreviewLayer {
                    return layer
                }
            }
            return nil
        }
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
        // todo(andrii-vysotskyi): match cardholder name
        return POScannedCard(number: number, expiration: expiration, cardholder: nil)
    }
}
