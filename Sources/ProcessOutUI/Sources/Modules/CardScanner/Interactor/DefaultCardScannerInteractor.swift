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
        cameraSession: CameraSession,
        cardRecognitionSession: CardRecognitionSession,
        logger: POLogger,
        completion: @escaping (Result<POScannedCard, POFailure>) -> Void
    ) {
        self.cameraSession = cameraSession
        self.cardRecognitionSession = cardRecognitionSession
        self.logger = logger
        self.completion = completion
        super.init(state: .idle)
    }

    // MARK: - CardScannerInteractor

    override func start() {
        guard case .idle = state else {
            return
        }
        Task { @MainActor in
//            await cardRecognitionSession.setRegionOfInterestAspectRatio(
//                Constants.cardAspectRatio
//            )
            await cardRecognitionSession.setDelegate(self)
            if await cameraSession.start(), await cardRecognitionSession.setCameraSession(cameraSession) {
                state = .started(.init(captureSession: await cameraSession.captureSession))
            } else {
                setFailureState(with: .init(message: "Unable to start scanning.", code: .generic(.mobile)))
            }
        }
        state = .starting
    }

    override func cancel() {
        switch state {
        case .starting, .started:
            Task { @MainActor in
                await cardRecognitionSession.stop()
                await cardRecognitionSession.setDelegate(nil)
                await cameraSession.stop()
            }
        default:
            break
        }
        setFailureState(with: .init(message: "Card scanning has been canceled.", code: .cancelled))
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let cardAspectRatio: CGFloat = 1.586 // ISO/IEC 7810 based
    }

    // MARK: - Private Properties

    private let cameraSession: CameraSession
    private let cardRecognitionSession: CardRecognitionSession
    private let logger: POLogger
    private let completion: (Result<POScannedCard, POFailure>) -> Void

    // MARK: - Success State

    private func setSuccessState(with card: POScannedCard) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set success state with: \(card).")
        } else {
            state = .completed(.success(card))
            completion(.success(card))
        }
    }

    // MARK: - Failure State

    private func setFailureState(with failure: POFailure) {
        if state.isSink {
            logger.debug("Already in a sink state, ignoring attempt to set failure state with: \(failure).")
        } else {
            state = .completed(.failure(failure))
            completion(.failure(failure))
        }
    }
}

extension DefaultCardScannerInteractor: CardRecognitionSessionDelegate {

    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognize card: POScannedCard) {
        Task {
            await session.setDelegate(nil)
            await session.stop()
        }
        setSuccessState(with: card)
    }
}
