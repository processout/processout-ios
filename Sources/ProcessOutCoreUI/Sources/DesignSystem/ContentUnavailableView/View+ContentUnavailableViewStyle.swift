//
//  View+ContentUnavailableViewStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.01.2025.
//

import SwiftUI

extension View {

    /// Sets the style for content unavailable views within this view.
    public func poContentUnavailableViewStyle(_ style: any POContentUnavailableViewStyle) -> some View {
        environment(\.poContentUnavailableViewStyle, style)
    }
}

extension EnvironmentValues {

    /// The style to apply to content unavailable views.
    @MainActor
    public internal(set) var poContentUnavailableViewStyle: any POContentUnavailableViewStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POContentUnavailableViewStyle)? = nil
    }
}
