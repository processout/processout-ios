//
//  View+ButtonLoading.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.09.2023.
//

import SwiftUI

extension View {

    /// Adds a condition that controls whether button with a `POButtonStyle` should show loading indicator.
    @_spi(PO)
    public func buttonLoading(_ isLoading: Bool) -> some View {
        environment(\.isButtonLoading, isLoading)
    }
}

extension EnvironmentValues {

    /// Indicates whether button is currently in loading state. It is expected that
    /// `ButtonStyle` implementation should respond to this environment
    /// changes (see ``POButtonStyle`` as a reference).
    public var isButtonLoading: Bool {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = false
    }
}
