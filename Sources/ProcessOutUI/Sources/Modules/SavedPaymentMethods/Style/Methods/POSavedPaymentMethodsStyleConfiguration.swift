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

    /// Card scanner title.
    public let title: AnyView

    /// Card scanner description.
    public let description: AnyView

    /// Cancel button.
    public let cancelButton: AnyView

    /// Creates configuration.
    init(
        @ViewBuilder title: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder cancelButton: () -> some View
    ) {
        self.title = AnyView(title())
        self.description = AnyView(description())
        self.cancelButton = AnyView(cancelButton())
    }
}
