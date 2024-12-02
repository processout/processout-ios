//
//  CardScannerInteractorState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.11.2024.
//

import AVFoundation
import ProcessOut

enum CardScannerInteractorState: InteractorState {

    struct Started {

        /// Capture session.
        let captureSession: AVCaptureSession

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
