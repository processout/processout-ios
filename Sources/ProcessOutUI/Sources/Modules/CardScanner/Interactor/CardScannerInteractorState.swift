//
//  CardScannerInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

import AVFoundation
import ProcessOut

enum CardScannerInteractorState: InteractorState {

    struct Value<T> {

        /// Current value.
        var current: T

        /// Desired value.
        var desired: T?

        /// Task that is responsible for current update if any.
        var updateTask: Task<Void, Never>?
    }

    struct Started {

        /// Capture session.
        let captureSession: AVCaptureSession

        /// Boolean flag indicating whether torch is enabled.
        var isTorchEnabled: Value<Bool>

        /// Currently scanned card details.
        var card: POScannedCard?
    }

    /// Idle state.
    case idle

    /// Starting state.
    case starting

    /// Started state.
    case started(Started)

    /// Completed state.
    case completed(Result<POScannedCard, POFailure>)
}

extension CardScannerInteractorState {

    var isSink: Bool {
        if case .completed = self {
            return true
        }
        return false
    }
}
