//
//  CardScannerViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation

struct CardScannerViewModelState {

    struct Preview {

        /// Capture session.
        let captureSession: AVCaptureSession?

        /// Preview aspect ratio.
        let aspectRatio: CGFloat
    }

    /// Screen title.
    let title: String

    /// Preview.
    let preview: Preview
}

extension CardScannerViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [title, AnyHashable(preview.aspectRatio)]
    }
}
