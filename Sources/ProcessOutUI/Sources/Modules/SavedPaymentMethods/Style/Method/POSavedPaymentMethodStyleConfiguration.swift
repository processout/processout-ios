//
//  POSavedPaymentMethodStyleConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI

/// The properties of a saved payment method style.
@MainActor
public struct POSavedPaymentMethodStyleConfiguration {

    /// Payment method icon.
    public let icon: AnyView

    /// Payment method name.
    public let name: AnyView

    /// Payment method description.
    public let description: AnyView

    /// Delete button.
    public let deleteButton: AnyView

    /// Creates configuration.
    init(
        @ViewBuilder icon: () -> some View,
        @ViewBuilder name: () -> some View,
        @ViewBuilder description: () -> some View,
        @ViewBuilder deleteButton: () -> some View
    ) {
        self.icon = AnyView(icon())
        self.name = AnyView(name())
        self.description = AnyView(description())
        self.deleteButton = AnyView(deleteButton())
    }
}
