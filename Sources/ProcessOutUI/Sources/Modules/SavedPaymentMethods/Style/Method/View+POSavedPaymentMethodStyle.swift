//
//  View+POSavedPaymentMethodStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.12.2024.
//

import SwiftUI

extension View {

    /// Sets the style for saved payment method views within this view.
    @available(iOS 14, *)
    public func savedPaymentMethodStyle(_ style: any POSavedPaymentMethodStyle) -> some View {
        environment(\.savedPaymentMethodStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    /// The style to apply to saved payment method views.
    @MainActor
    public internal(set) var savedPaymentMethodStyle: any POSavedPaymentMethodStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POSavedPaymentMethodStyle)? = nil
    }
}
