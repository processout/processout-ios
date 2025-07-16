//
//  POAsyncImage+Resource.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI
@_spi(PO) import ProcessOut
@_spi(PO) import ProcessOutCoreUI

extension POAsyncImage {

    /// Loads and displays an image from the specified resource.
    /// - NOTE: implementation uses shared `ProcessOut` instance to load image.
    init<Placeholder: View>(
        resource: POImageRemoteResource,
        transaction: Transaction = Transaction(animation: .default),
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) where Content == _ConditionalContent<Image, Placeholder> {
        self.init(resource: resource, transaction: transaction, placeholder: placeholder) { phase in
            if case .success(let image) = phase {
                return ViewBuilder.buildEither(first: image)
            } else {
                return ViewBuilder.buildEither(second: placeholder())
            }
        }
    }

    /// Loads and displays an image from the specified resource.
    /// - NOTE: implementation uses shared `ProcessOut` instance to load image.
    init<Placeholder: View>(
        resource: POImageRemoteResource,
        transaction: Transaction = Transaction(animation: .default),
        @ViewBuilder placeholder: @escaping () -> Placeholder,
        @ViewBuilder content: @escaping (POAsyncImagePhase) -> Content
    ) {
        let image = { @Sendable @MainActor in
            let uiImage = await ProcessOut.shared.images.image(resource: resource)
            return uiImage.map(Image.init)
        }
        self.init(id: resource, image: image, transaction: transaction, content: content)
    }
}
