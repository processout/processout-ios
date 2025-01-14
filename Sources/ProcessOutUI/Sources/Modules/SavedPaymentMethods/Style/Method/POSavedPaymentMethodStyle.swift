//
//  POSavedPaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all save payment method
/// views within a view hierarchy.
@MainActor
public protocol POSavedPaymentMethodStyle: Sendable {

    /// A view representing the appearance and interaction of a `POSavedPaymentMethodStyle`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POSavedPaymentMethodStyle`.
    ///
    /// - Parameter configuration : The properties of the saved payment method view.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a card scanner.
    typealias Configuration = POSavedPaymentMethodStyleConfiguration
}
