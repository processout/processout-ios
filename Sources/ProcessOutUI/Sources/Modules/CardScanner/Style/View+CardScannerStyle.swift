//
//  View+CardScannerStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.12.2024.
//

import SwiftUI

@_spi(PO)
extension View {

    /// Sets the style for card scanner views within this view.
    @available(iOS 14, *)
    public func cardScannerStyle(_ style: any POCardScannerStyle) -> some View {
        environment(\.cardScannerStyle, style)
    }
}

@available(iOS 14, *)
@_spi(PO)
extension EnvironmentValues {

    /// The style to apply to card scanner views.
    @MainActor
    public var cardScannerStyle: any POCardScannerStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POCardScannerStyle)? = nil
    }
}
