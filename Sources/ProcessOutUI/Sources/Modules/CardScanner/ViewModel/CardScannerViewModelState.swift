//
//  CardScannerViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation
@_spi(PO) import ProcessOutCoreUI

struct CardScannerViewModelState {

    struct Preview {

        /// Capture session.
        let captureSession: AVCaptureSession?

        /// Preview aspect ratio.
        let aspectRatio: CGFloat
    }

    struct Card {

        /// Card number.
        let number: String

        /// Card expiration.
        let expiration: String?

        /// Cardholder name.
        let cardholderName: String?
    }

    /// Screen title.
    let title: String?

    /// Description.
    let description: String?

    /// Preview.
    let preview: Preview

    /// Recognized card details.
    let recognizedCard: Card?

    /// Cancel button.
    let cancelButton: POButtonViewModel?
}

extension CardScannerViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [title, description, AnyHashable(preview.aspectRatio)]
    }
}
