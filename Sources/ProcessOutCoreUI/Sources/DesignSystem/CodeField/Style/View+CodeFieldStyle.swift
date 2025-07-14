//
//  View+CodeFieldStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.06.2024.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    func codeFieldStyle(_ style: some CodeFieldStyle) -> some View {
        environment(\.codeFieldStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var codeFieldStyle: any CodeFieldStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (any CodeFieldStyle)? = nil
    }
}
