//
//  View+ActionsContainerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 20.10.2023.
//

import SwiftUI

extension View {

    @available(iOS 14, *)
    @_spi(PO)
    public func actionsContainerStyle(_ style: POActionsContainerStyle) -> some View {
        environment(\.actionsContainerStyle, style)
    }
}

@available(iOS 14, *)
extension EnvironmentValues {

    var actionsContainerStyle: POActionsContainerStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POActionsContainerStyle.default
    }
}
