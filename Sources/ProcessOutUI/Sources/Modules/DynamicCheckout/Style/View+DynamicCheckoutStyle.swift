//
//  View+DynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI

extension View {

    /// Sets the style for dynamic checkout views within this view.
    @available(iOS 14, *)
    public func dynamicCheckoutStyle(_ style: PODynamicCheckoutStyle) -> some View {
        environment(\.dynamicCheckoutStyle, style)
    }
}

@available(iOS 14, *)
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
