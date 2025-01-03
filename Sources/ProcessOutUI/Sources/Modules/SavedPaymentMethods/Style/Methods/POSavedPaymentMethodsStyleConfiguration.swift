//
//  POSavedPaymentMethodsStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import SwiftUI

/// The properties of a saved payment methods style.
@MainActor
public struct POSavedPaymentMethodsStyleConfiguration {

    // MARK: - Getting the view

    /// Saved payment methods view title.
    public let title: AnyView

    /// Payment methods.
    public let paymentMethods: AnyView

    /// Message.
    public let message: AnyView

    /// Cancel button.
    public let cancelButton: AnyView

    // MARK: - Managing the view state

    /// Boolean value indicating whether screen is currently being loaded.
    public let isLoading: Bool

    /// Creates configuration.
    init(
        @ViewBuilder title: () -> some View,
        @ViewBuilder paymentMethods: () -> some View,
        @ViewBuilder message: () -> some View,
        @ViewBuilder cancelButton: () -> some View,
        isLoading: Bool
    ) {
        self.title = AnyView(title())
        self.paymentMethods = AnyView(paymentMethods())
        self.message = AnyView(message())
        self.cancelButton = AnyView(cancelButton())
        self.isLoading = isLoading
    }
}
