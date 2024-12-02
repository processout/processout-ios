//
//  DefaultCardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation
import UIKit
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

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
        switch interactor.state {
        case .idle, .starting:
            update(withCaptureSession: nil, scannedCard: nil)
        case .started(let currentState):
            update(withCaptureSession: currentState.captureSession, scannedCard: currentState.card)
        case .completed:
            return
        }
    }

    private func update(withCaptureSession captureSession: AVCaptureSession?, scannedCard: POScannedCard?) {
        state = .init(
            title: title,
            description: description,
            preview: .init(
                captureSession: captureSession, aspectRatio: Constants.previewAspectRatio
            ),
            recognizedCard: cardViewModel(with: scannedCard),
            cancelButton: cancelButtonViewModel
        )
    }

    // MARK: - Misc

    private var title: String? {
        let title = interactor.configuration.title ?? String(resource: .CardScanner.title)
        guard !title.isEmpty else {
            return nil
        }
        return description
    }

    private var description: String? {
        let description = interactor.configuration.description ?? String(resource: .CardScanner.description)
        guard !description.isEmpty else {
            return nil
        }
        return description
    }

    private var cancelButtonViewModel: POButtonViewModel? {
        guard let configuration = interactor.configuration.cancelButton else {
            return nil
        }
        let viewModel = POButtonViewModel(
            id: "cancel-button",
            title: configuration.title ?? String(resource: .CardScanner.cancelButton),
            icon: configuration.icon,
            confirmation: configuration.confirmation.map { .cancel(with: $0, onAppear: nil) },
            action: { [weak self] in
                self?.interactor.cancel()
            }
        )
        return viewModel
    }

    private func cardViewModel(with card: POScannedCard?) -> CardScannerViewModelState.Card? {
        guard let card else {
            return nil
        }
        return .init(number: card.number, expiration: card.expiration?.description, cardholderName: card.cardholderName)
    }
}
