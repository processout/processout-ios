//
//  View+TextFieldStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.01.2025.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    public func poTextFieldStyle<Style: POTextFieldStyle>(_ style: Style) -> some View {
        environment(\.poTextFieldStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var poTextFieldStyle: any POTextFieldStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POTextFieldStyle)? = nil
    }
}
