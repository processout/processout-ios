//
//  EnvironmentValues+ButtonBrandColor.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.04.2024.
//

import SwiftUI

extension View {

    /// Adds a condition that controls whether button with a `POButtonStyle` should show loading indicator.
    @_spi(PO) public func buttonBrandColor(_ color: Color) -> some View {
        environment(\.poButtonBrandColor, color)
    }
}

extension EnvironmentValues {

    /// Indicates whether button is currently in loading state. It is expected that `ButtonStyle` implementation
    /// should respond to this environment changes (see ``POButtonStyle`` as a reference).
    public var poButtonBrandColor: Color {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = Color(poResource: .Surface.background)
    }
}
