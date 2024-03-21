//
//  View+DynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI

extension View {

    /// Sets the style for card tokenization views within this view.
    public func dynamicCheckoutStyle(_ style: PODynamicCheckoutStyle) -> some View {
        environment(\.dynamicCheckoutStyle, style)
    }
}

extension EnvironmentValues {

    var dynamicCheckoutStyle: PODynamicCheckoutStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = PODynamicCheckoutStyle.default
    }
}
