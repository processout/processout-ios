//
//  View+POLabeledContentStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    @available(iOS 14, *)
    public func poLabeledContentStyle(_ style: any POLabeledContentStyle) -> some View {
        environment(\.poLabeledContentStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    @MainActor
    var poLabeledContentStyle: any POLabeledContentStyle {
        get { self[Key.self] ?? .automatic }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POLabeledContentStyle)? = nil
    }
}
