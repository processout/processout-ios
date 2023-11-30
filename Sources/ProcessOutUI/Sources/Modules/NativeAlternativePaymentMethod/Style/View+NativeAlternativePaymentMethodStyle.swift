//
//  View+NativeAlternativePaymentStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.11.2023.
//

import SwiftUI

extension View {

    /// Sets the style for native APM views within this view.
    @available(iOS 14, *)
    public func nativeAlternativePaymentStyle(_ style: PONativeAlternativePaymentStyle) -> some View {
        environment(\.nativeAlternativePaymentStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    var nativeAlternativePaymentStyle: PONativeAlternativePaymentStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = PONativeAlternativePaymentStyle.default
    }
}
