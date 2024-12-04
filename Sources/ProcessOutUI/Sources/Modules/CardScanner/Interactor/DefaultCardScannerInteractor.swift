//
//  DefaultCardScannerInteractor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

import AVFoundation
@_spi(PO) import ProcessOut

final class DefaultCardScannerInteractor: BaseInteractor<CardScannerInteractorState>, CardScannerInteractor {

    init(
        configuration: POCardScannerConfiguration,
        cameraSession: CameraSession,
        cardRecognitionSession: CardRecognitionSession,
        logger: POLogger,
        completion: @escaping (Result<POScannedCard, POFailure>) -> Void
    ) {
        self.configuration = configuration
        self.cameraSession = cameraSession
        self.cardRecognitionSession = cardRecognitionSession
        self.logger = logger
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardScannerInteractor

    let configuration: POCardScannerConfiguration

    override func start() {
        guard case .idle = state else {
            return
        }
        Task { @MainActor in
            await cardRecognitionSession.setDelegate(self)
            if await cameraSession.start(), await cardRecognitionSession.setCameraSession(cameraSession) {
                let captureSession = await cameraSession.captureSession
                let isTorchEnabled = await cameraSession.isTorchEnabled
                setStartedState(captureSession: captureSession, isTorchEnabled: isTorchEnabled)
            } else {
                setFailureState(with: .init(message: "Unable to start scanning.", code: .generic(.mobile)))
            }
        }
        state = .starting
    }

    override func cancel() {
        setFailureState(with: .init(message: "Card scanning has been canceled.", code: .cancelled))
    }

    func setTorchEnabled(_ isEnabled: Bool) async {
        guard await cameraSession.setTorchEnabled(isEnabled),
              case .started(let currentState) = state else {
            return
        }
        var newState = currentState
        newState.isTorchEnabled = isEnabled
        state = .started(newState)
    }

    // MARK: - Private Properties

    private let cameraSession: CameraSession
    private let cardRecognitionSession: CardRecognitionSession
    private let logger: POLogger
    private let completion: (Result<POScannedCard, POFailure>) -> Void

    // MARK: - Started State

    private func setStartedState(captureSession: AVCaptureSession, isTorchEnabled: Bool) {
        guard case .starting = state else {
            return
        }
        let newState = State.Started(captureSession: captureSession, isTorchEnabled: isTorchEnabled)
        state = .started(newState)
    }

    // MARK: - Success State

    private func setSuccessState(with card: POScannedCard) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set success state with: \(card).")
        } else {
            state = .completed(.success(card))
            completion(.success(card))
        }
        stopSessions()
    }

    // MARK: - Failure State

    private func setFailureState(with failure: POFailure) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(failure).")
        } else {
            state = .completed(.failure(failure))
            completion(.failure(failure))
        }
        stopSessions()
    }

    // MARK: - Misc

    private func stopSessions() {
        Task { @MainActor in
            await cardRecognitionSession.setDelegate(nil)
            await cameraSession.stop()
        }
    }

    private func setRecognizedCard(_ card: POScannedCard?) {
        guard case .started(let currentState) = state else {
            logger.debug("Ignoring attempt to update card in unsupported state: \(state).")
            return
        }
        var newState = currentState
        newState.card = card
        self.state = .started(newState)
    }
}

extension DefaultCardScannerInteractor: CardRecognitionSessionDelegate {

    func cardRecognitionSession(_ session: CardRecognitionSession, willValidateCard card: POScannedCard) {
        setRecognizedCard(card)
    }

    func cardRecognitionSession(_ session: CardRecognitionSession, didFailToValidateCard card: POScannedCard) {
        setRecognizedCard(nil)
    }

    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard) {
        setSuccessState(with: card)
    }
}
