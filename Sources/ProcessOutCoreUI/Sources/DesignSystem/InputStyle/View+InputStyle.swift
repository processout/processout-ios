//
//  View+InputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 25.09.2023.
//

import SwiftUI

extension View {

    @_spi(PO)
    public func inputStyle(_ style: POInputStyle) -> some View {
        environment(\.inputStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var inputStyle: POInputStyle {
        get { self[Key.self] ?? .medium }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: POInputStyle? = nil
    }
}
