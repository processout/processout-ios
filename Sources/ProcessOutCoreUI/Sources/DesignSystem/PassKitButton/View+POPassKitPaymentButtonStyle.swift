//
//  View+POPassKitPaymentButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 27.05.2024.
//

import SwiftUI

extension View {

    /// Changes PassKit button style.
    @_spi(PO)
    @available(iOS 14.0, *)
    public func passKitPaymentButtonStyle(_ style: POPassKitPaymentButtonStyle) -> some View {
        environment(\.passKitPaymentButtonStyle, style)
    }
}

@available(iOS 14.0, *)
extension EnvironmentValues {

    /// PassKit button style.
    @MainActor
    var passKitPaymentButtonStyle: POPassKitPaymentButtonStyle {
        get { self[Key.self] ?? .init() }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: POPassKitPaymentButtonStyle? = nil
    }
}
