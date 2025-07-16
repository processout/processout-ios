//
//  View+POSavedPaymentMethodsStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI

extension View {

    /// Sets the style for saved payment methods views within this view.
    public func savedPaymentMethodsStyle(_ style: any POSavedPaymentMethodsStyle) -> some View {
        environment(\.savedPaymentMethodsStyle, style)
    }
}

extension EnvironmentValues {

    /// The style to apply to saved payment methods views.
    @MainActor
    public internal(set) var savedPaymentMethodsStyle: any POSavedPaymentMethodsStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POSavedPaymentMethodsStyle)? = nil
    }
}
