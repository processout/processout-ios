//
//  View+CardTokenizationStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension View {

    /// Sets the style for card tokenization views within this view.
    public func cardTokenizationStyle(_ style: POCardTokenizationStyle) -> some View {
        environment(\.cardTokenizationStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var cardTokenizationStyle: POCardTokenizationStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: POCardTokenizationStyle? = nil
    }
}
