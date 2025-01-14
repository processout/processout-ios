//
//  POSavedPaymentMethodsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI

/// A type that specifies the appearance and interaction of all save payment methods
/// views within a view hierarchy.
@MainActor
public protocol POSavedPaymentMethodsStyle: Sendable {

    /// A view representing the appearance and interaction of a `POSavedPaymentMethodsStyle`.
    associatedtype Body: View

    /// Returns the appearance and interaction content for a `POSavedPaymentMethodsStyle`.
    ///
    /// - Parameter configuration : The properties of the saved payment methods view.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    /// The properties of a card scanner.
    typealias Configuration = POSavedPaymentMethodsStyleConfiguration
}
