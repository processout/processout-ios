//
//  DefaultCardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.02.2024.
//

import Combine
import AVFoundation
@_spi(PO) import ProcessOut

final class DefaultCardScannerViewModel: CardScannerViewModel {

    init(cameraCoordinator: CameraCoordinator, cardRecognitionCoordinator: CardRecognitionCoordinator) {
        self.cameraCoordinator = cameraCoordinator
        self.cardRecognitionCoordinator = cardRecognitionCoordinator
        start()
    }

    // MARK: - CardScannerViewModel

    /// Screen title.
    var title: String {
        String(resource: .CardScanner.title)
    }

    /// Capture session.
    var captureSession: AVCaptureSession {
        cameraCoordinator.session
    }

    // MARK: - Private Properties

    private let cameraCoordinator: CameraCoordinator
    private let cardRecognitionCoordinator: CardRecognitionCoordinator

    // MARK: - Private Methods

    private func start() {
        cardRecognitionCoordinator.setCameraCoordinator(cameraCoordinator)
        cardRecognitionCoordinator.delegate = self

        cameraCoordinator.start()
        cardRecognitionCoordinator.start()

        // todo: detect any errors, like the fact that user didn't give camera permission
    }
}

extension DefaultCardScannerViewModel: CardRecognitionCoordinatorDelegate {

    func cardRecognitionCoordinator(_ coordinator: CardRecognitionCoordinator, didRecognizeCard card: POScannedCard) {
        // here coordinator should be stopped and completion should be called
        // NOP
    }
}
