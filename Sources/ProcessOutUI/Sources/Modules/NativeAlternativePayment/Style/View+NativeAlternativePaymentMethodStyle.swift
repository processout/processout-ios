//
//  View+NativeAlternativePaymentStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI

extension View {

    /// Sets the style for native APM views within this view.
    public func nativeAlternativePaymentStyle(_ style: PONativeAlternativePaymentStyle) -> some View {
        environment(\.nativeAlternativePaymentStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var nativeAlternativePaymentStyle: PONativeAlternativePaymentStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: PONativeAlternativePaymentStyle? = nil
    }
}
