//
//  POAsyncImage+Resource.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

@available(iOS 14, *)
extension POAsyncImage {

    /// Loads and displays an image from the specified resource.
    /// - NOTE: implementation uses shared `ProcessOut` instance to load image.
    init<Placeholder: View>(
        resource: POImageRemoteResource,
        transaction: Transaction = Transaction(),
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) where Content == _ConditionalContent<Image, Placeholder> {
        let image = { @Sendable @MainActor in
            let uiImage = await ProcessOut.shared.images.image(resource: resource)
            return uiImage.map(Image.init)
        }
        // swiftlint:disable:next identifier_name
        let _content: (POAsyncImagePhase) -> _ConditionalContent<Image, Placeholder> = { phase in
            if case .success(let image) = phase {
                return ViewBuilder.buildEither(first: image)
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
        self.init(image: image, transaction: transaction, content: _content)
    }
}
