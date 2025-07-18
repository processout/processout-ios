//
//  MessageView+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    public func messageViewStyle(_ style: any POMessageViewStyle) -> some View {
        environment(\.messageViewStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var messageViewStyle: any POMessageViewStyle {
        get { self[Key.self] ?? .toast }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POMessageViewStyle)? = nil
    }
}
