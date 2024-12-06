//
//  CardScannerViewModelState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.11.2024.
//

import AVFoundation
import SwiftUI
@_spi(PO) import ProcessOutCoreUI

struct CardScannerViewModelState {

    struct Preview {

        /// Preview source.
        let source: CameraSessionPreviewSource?

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

    /// Boolean value indicating whether torch is enabled.
    var isTorchEnabled: Binding<Bool>

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
