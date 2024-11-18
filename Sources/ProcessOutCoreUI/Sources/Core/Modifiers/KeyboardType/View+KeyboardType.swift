//
//  View+KeyboardType.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.10.2023.
//

import SwiftUI

extension View {

    /// Sets the keyboard type for this view. In addition to calling the native counterpart,
    /// the implementation also exposes given type as an environment so works with `POTextField`.
    @_spi(PO)
    public func poKeyboardType(_ type: UIKeyboardType) -> some View {
        environment(\.poKeyboardType, type).keyboardType(type)
    }
}

extension EnvironmentValues {

    /// Keyboard type.
    var poKeyboardType: UIKeyboardType {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue = UIKeyboardType.default
    }
}
