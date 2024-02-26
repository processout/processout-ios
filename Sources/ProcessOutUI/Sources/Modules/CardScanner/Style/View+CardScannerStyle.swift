//
//  View+CardScannerStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.02.2024.
//

import SwiftUI

extension View {

    /// Sets the style for card tokenization views within this view.
    @_spi(PO) public func cardScannerStyle(_ style: POCardScannerStyle) -> some View {
        environment(\.cardScannerStyle, style)
    }
}

extension EnvironmentValues {

    var cardScannerStyle: POCardScannerStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POCardScannerStyle.default
    }
}
