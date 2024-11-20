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
        var captureSession: AVCaptureSession?

        /// Preview aspect ratio.
        let aspectRatio: CGFloat
    }

    /// Screen title.
    let title: String

    /// Preview.
    var preview: Preview

    /// Boolean flag indicating wh
    var didComplete: Bool
}

extension CardScannerViewModelState: AnimationIdentityProvider {

    var animationIdentity: AnyHashable {
        [title, AnyHashable(preview.aspectRatio)]
    }
}
