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

    /// A view representing the appearance and interaction of a `POCardScannerStyle`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POCardScannerView`.
    ///
    /// - Parameter configuration : The properties of the card scanner.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// Background color.
    var backgroundColor: Color { get }

    /// The properties of a card scanner.
    typealias Configuration = POCardScannerStyleConfiguration
}
