//
//  View+ControlSelected.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension View {

    @_spi(PO)
    public func controlSelected(_ isSelected: Bool) -> some View {
        environment(\.poControlSelected, isSelected)
    }
}

extension EnvironmentValues {

    /// Indicates whether radio button is currently selected. It is expected that
    /// `ButtonStyle` implementation should respond to this environment
    /// changes (see ``PORadioButtonStyle`` as a reference).
    public var poControlSelected: Bool {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    /// Indicates whether radio button is currently selected. It is expected that
    /// `ButtonStyle` implementation should respond to this environment
    /// changes (see ``PORadioButtonStyle`` as a reference).
    @available(*, deprecated, renamed: "poControlSelected")
    public var isRadioButtonSelected: Bool {
        get { poControlSelected }
        set { poControlSelected = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = false
    }
}
