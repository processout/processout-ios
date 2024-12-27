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

    /// Saved payment methods view title.
    public let title: AnyView

    /// Payment methods.
    public let paymentMethods: AnyView

    /// Cancel button.
    public let cancelButton: AnyView

    /// Creates configuration.
    init(
        @ViewBuilder title: () -> some View,
        @ViewBuilder paymentMethods: () -> some View,
        @ViewBuilder cancelButton: () -> some View
    ) {
        self.title = AnyView(title())
        self.paymentMethods = AnyView(paymentMethods())
        self.cancelButton = AnyView(cancelButton())
    }
}
