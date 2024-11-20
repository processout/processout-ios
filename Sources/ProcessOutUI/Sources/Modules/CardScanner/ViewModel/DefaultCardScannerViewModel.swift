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

    init() {
        self.cameraSession = .init()
        self.cardRecognitionSession = .init()
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
        // todo(andrii-vysotskyi): abort on error
        Task { @MainActor in
            await cardRecognitionSession.setRegionOfInterestAspectRatio(Constants.previewAspectRatio)
            _ = await cameraSession.start()
            _ = await cardRecognitionSession.setCameraSession(cameraSession)
            state.preview.captureSession = await cameraSession.captureSession
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let previewAspectRatio: CGFloat = 1.586 // ISO/IEC 7810 based
    }

    // MARK: - Private Properties

    private let cameraSession: CameraSession
    private let cardRecognitionSession: CardRecognitionSession

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
