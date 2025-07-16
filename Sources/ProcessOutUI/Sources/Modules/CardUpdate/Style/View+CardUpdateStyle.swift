//
//  View+CardUpdateStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 03.11.2023.
//

import SwiftUI

extension View {

    /// Sets the style for card update views within this view.
    public func cardUpdateStyle(_ style: POCardUpdateStyle) -> some View {
        environment(\.cardUpdateStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var cardUpdateStyle: POCardUpdateStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: POCardUpdateStyle? = nil
    }
}
