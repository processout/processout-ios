//
//  View+DynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI

extension View {

    /// Sets the style for card tokenization views within this view.
    @available(iOS 14, *)
    @_spi(PO)
    public func dynamicCheckoutStyle(_ style: PODynamicCheckoutStyle) -> some View {
        environment(\.dynamicCheckoutStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    @MainActor
    var dynamicCheckoutStyle: PODynamicCheckoutStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: PODynamicCheckoutStyle? = nil
    }
}
