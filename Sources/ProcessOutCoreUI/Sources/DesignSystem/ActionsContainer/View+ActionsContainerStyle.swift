//
//  View+ActionsContainerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension View {

    @_spi(PO)
    public func actionsContainerStyle(_ style: POActionsContainerStyle) -> some View {
        environment(\.actionsContainerStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var actionsContainerStyle: POActionsContainerStyle {
        get { self[Key.self] ?? .default }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue: POActionsContainerStyle? = nil
    }
}
