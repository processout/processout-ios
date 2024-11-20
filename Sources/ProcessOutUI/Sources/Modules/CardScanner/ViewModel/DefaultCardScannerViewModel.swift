//
//  DefaultCardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import Combine
import UIKit
@_spi(PO) import ProcessOut

final class DefaultCardScannerViewModel: ViewModel {

    init(
        cameraSession: CameraSession,
        cardRecognitionSession: CardRecognitionSession,
        completion: @escaping (Result<POScannedCard, POFailure>) -> Void
    ) {
        self.cameraSession = cameraSession
        self.cardRecognitionSession = cardRecognitionSession
        self.completion = completion
        commonInit()
    }

    deinit {
        Task { [cameraSession] in await cameraSession.stop() }
    }

    // MARK: - CardScannerViewModel

    var state: CardScannerViewModelState {
        get { _state }
        set { _state = newValue }
    }

    func start() {
        Task { @MainActor in
            await cardRecognitionSession.setRegionOfInterestAspectRatio(
                Constants.previewAspectRatio
            )
            await cardRecognitionSession.setDelegate(self)
            if await cameraSession.start(), await cardRecognitionSession.setCameraSession(cameraSession) {
                state.preview.captureSession = await cameraSession.captureSession
            } else {
                completion(.failure(.init(message: "Unable to start scanning.", code: .generic(.mobile))))
            }
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let previewAspectRatio: CGFloat = 1.586 // ISO/IEC 7810 based
    }

    // MARK: - Private Properties

    private let cameraSession: CameraSession
    private let cardRecognitionSession: CardRecognitionSession
    private let completion: (Result<POScannedCard, POFailure>) -> Void

    @AnimatablePublished
    private var _state: CardScannerViewModelState! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Private Methods

    private func commonInit() {
        state = .init(
            title: String(resource: .CardScanner.title),
            preview: .init(captureSession: nil, aspectRatio: Constants.previewAspectRatio)
        )
    }
}

extension DefaultCardScannerViewModel: CardRecognitionSessionDelegate {

    func cardRecognitionSession(_ session: CardRecognitionSession, didRecognize card: POScannedCard) {
        // todo(andrii-vysotskyi): ensure completion is called only once.
        Task {
            await session.setDelegate(nil)
            await session.stop()
        }
        completion(.success(card))
    }
}
