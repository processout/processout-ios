//
//  View+ControlWidth.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.12.2024.
//

import SwiftUI

/// An enumeration that defines the width of a control in the user interface.
public enum POControlWidth: CaseIterable, Hashable, Sendable {

    /// A control width that adjusts to fit its content.
    case regular

    /// A control width that expands to fill the available space.
    case expanded
}

extension View {

    /// Sets the width configuration for controls within this view.
    @_spi(PO)
    @ViewBuilder
    public func controlWidth(_ controlWidth: POControlWidth) -> some View {
        environment(\.poControlWidth, controlWidth)
    }
}

extension EnvironmentValues {

    /// The width configuration to apply to controls within a view.
    ///
    /// The default is ``POControlWidth/expanded``.
    public internal(set) var poControlWidth: POControlWidth {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue = POControlWidth.expanded
    }
}
