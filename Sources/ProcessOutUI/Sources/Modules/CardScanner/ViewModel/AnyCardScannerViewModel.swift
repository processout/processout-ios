//
//  AnyCardScannerViewModel.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.02.2024.
//

import Combine
import AVFoundation

final class AnyCardScannerViewModel: CardScannerViewModel {

    init<ViewModel: CardScannerViewModel>(erasing viewModel: ViewModel) {
        self.base = viewModel
        cancellable = viewModel.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }
    }

    let base: any CardScannerViewModel

    // MARK: - CardScannerViewModel

    var title: String {
        base.title
    }

    var captureSession: AVCaptureSession {
        base.captureSession
    }

    // MARK: - Private Properties

    private var cancellable: AnyCancellable?
}
