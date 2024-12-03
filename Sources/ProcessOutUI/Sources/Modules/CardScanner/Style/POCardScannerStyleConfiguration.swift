//
//  POCardScannerStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.12.2024.
//

import SwiftUI

/// The properties of a card scanner style.
@_spi(PO)
@MainActor
public struct POCardScannerStyleConfiguration {

    @MainActor
    public struct Card {

        /// Card number.
        public let number: Text

        /// Card expiration.
        public let expiration: Text?

        /// Cardholder name.
        public let cardholderName: Text?

        init(
            @ViewBuilder number: () -> Text,
            @ViewBuilder expiration: () -> Text?,
            @ViewBuilder cardholderName: () -> Text?
        ) {
            self.number = number()
            self.expiration = expiration()
            self.cardholderName = cardholderName()
        }
    }

    /// Card scanner title.
    public let title: AnyView

    /// Card scanner description.
    public let description: AnyView

    /// Video preview view.
    public let videoPreview: AnyView

    /// Cancel button.
    public let cancelButton: AnyView

    /// Card details.
    public let card: Card?

    /// Creates configuration.
    init(
        @ViewBuilder title: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder videoPreview: () -> some View,
        @ViewBuilder cancelButton: () -> some View,
        card: Card?
    ) {
        self.title = AnyView(title())
        self.description = AnyView(description())
        self.videoPreview = AnyView(videoPreview())
        self.cancelButton = AnyView(cancelButton())
        self.card = card
    }
}
