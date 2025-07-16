//
//  View+CardScannerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

extension View {

    /// Sets the style for card scanner views within this view.
    public func cardScannerStyle(_ style: any POCardScannerStyle) -> some View {
        environment(\.cardScannerStyle, style)
    }
}

extension EnvironmentValues {

    /// The style to apply to card scanner views.
    @MainActor
    public internal(set) var cardScannerStyle: any POCardScannerStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POCardScannerStyle)? = nil
    }
}
