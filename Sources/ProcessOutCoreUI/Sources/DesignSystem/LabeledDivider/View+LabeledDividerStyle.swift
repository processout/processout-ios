//
//  View+LabeledDividerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    public func labeledDividerStyle(_ style: POLabeledDividerStyle) -> some View {
        environment(\.labeledDividerStyle, style)
    }
}

extension EnvironmentValues {

    var labeledDividerStyle: POLabeledDividerStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = POLabeledDividerStyle()
    }
}
