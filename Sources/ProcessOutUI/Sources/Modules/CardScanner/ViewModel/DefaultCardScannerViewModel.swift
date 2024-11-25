//
//  DefaultCardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation
import UIKit
@_spi(PO) import ProcessOut

final class DefaultCardScannerViewModel: ViewModel {

    init(interactor: some CardScannerInteractor) {
        self.interactor = interactor
        observeChanges(interactor: interactor)
    }

    deinit {
        Task { [interactor] in await interactor.cancel() }
    }

    // MARK: - CardScannerViewModel

    var state: CardScannerViewModelState {
        get { _state }
        set { _state = newValue }
    }

    func start() {
        $_state.performWithoutAnimation(interactor.start)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let previewAspectRatio: CGFloat = 1.586 // ISO/IEC 7810 based
    }

    // MARK: - Private Properties

    private let interactor: any CardScannerInteractor

    @AnimatablePublished
    private var _state: CardScannerViewModelState! // swiftlint:disable:this implicitly_unwrapped_optional

    // MARK: - Interactor Observation

    private func observeChanges(interactor: some Interactor) {
        interactor.didChange = { [weak self] in
            self?.updateWithInteractorState()
        }
        updateWithInteractorState()
    }

    private func updateWithInteractorState() {
        let captureSession: AVCaptureSession?
        switch interactor.state {
        case .idle:
            captureSession = nil
        case .starting:
            captureSession = nil
        case .started(let currentState):
            captureSession = currentState.captureSession
        case .completed:
            return
        }
        state = .init(
            title: String(resource: .CardScanner.title),
            preview: .init(captureSession: captureSession, aspectRatio: Constants.previewAspectRatio)
        )
    }
}
