//
//  POCardScannerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all card scanners
/// within a view hierarchy.
@_spi(PO)
@MainActor
public protocol POCardScannerStyle: Sendable {

    /// A view representing the appearance and interaction of a `POPicker`.
    associatedtype Body: View

    /// The properties of a card scanner.
    typealias Configuration = POCardScannerStyleConfiguration

    /// Returns the appearance and interaction content for a `POCardScannerView`.
    ///
    /// - Parameter configuration : The properties of the card scanner.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
}

/// /// The properties of a card scanner.
@_spi(PO)
@MainActor
public struct POCardScannerStyleConfiguration {

    /// Card scanner title.
    public let title: AnyView

    /// Card scanner description.
    public let description: AnyView

    /// Video preview view.
    public let videoPreview: AnyView

    /// Cancel button.
    public let cancelButton: AnyView

    /// Creates configuration.
    init(
        @ViewBuilder title: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder videoPreview: () -> some View,
        @ViewBuilder cancelButton: () -> some View
    ) {
        self.title = AnyView(title())
        self.description = AnyView(description())
        self.videoPreview = AnyView(videoPreview())
        self.cancelButton = AnyView(cancelButton())
    }
}
