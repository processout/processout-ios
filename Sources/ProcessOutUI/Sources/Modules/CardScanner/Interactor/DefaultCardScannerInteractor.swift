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
            if await cameraSession.start() {
                await cardRecognitionSession.setCameraSession(cameraSession)
                let previewSource = cameraSession.previewSource
                let isTorchEnabled = await cameraSession.isTorchEnabled
                setStartedState(previewSource: previewSource, isTorchEnabled: isTorchEnabled)
            } else {
                setFailureState(with: .init(message: "Unable to start scanning.", code: .Mobile.generic))
            }
        }
        state = .starting
    }

    override func cancel() {
        setFailureState(with: .init(message: "Card scanning has been canceled.", code: .Mobile.cancelled))
    }

    func setTorchEnabled(_ isEnabled: Bool) {
        guard case .started(let currentState) = state else {
            logger.debug("Ignoring attempt to change torch state in unsupported state: \(state).")
            return
        }
        if let task = currentState.isTorchEnabled.updateTask {
            task.cancel()
        }
        var newState = currentState
        newState.isTorchEnabled.desired = isEnabled
        newState.isTorchEnabled.updateTask = Task {
            await enableTorch(isEnabled)
        }
        state = .started(newState)
    }

    // MARK: - Private Properties

    private let cameraSession: CameraSession
    private let cardRecognitionSession: CardRecognitionSession
    private let logger: POLogger
    private let completion: (Result<POScannedCard, POFailure>) -> Void

    // MARK: - Started State

    private func setStartedState(previewSource: CameraSessionPreviewSource, isTorchEnabled: Bool) {
        guard case .starting = state else {
            return
        }
        let newState = State.Started(
            previewSource: previewSource, isTorchEnabled: .init(current: isTorchEnabled)
        )
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

    // MARK: - Torch

    private func enableTorch(_ isEnabled: Bool) async {
        await cameraSession.setTorchEnabled(isEnabled)
        let isTorchEnabled = await cameraSession.isTorchEnabled
        guard case .started(let currentState) = state, !Task.isCancelled else {
            return
        }
        var newState = currentState
        newState.isTorchEnabled = .init(current: isTorchEnabled)
        state = .started(newState)
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

    func cardRecognitionSession(_ session: CardRecognitionSession, didUpdateCard card: POScannedCard?) {
        setRecognizedCard(card)
    }

    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognizeCard card: POScannedCard) {
        setSuccessState(with: card)
    }

    func cardRecognitionSession(_ session: CardRecognitionSession, regionOfInterestInside rect: CGRect) -> CGRect? {
        nil
    }
}
