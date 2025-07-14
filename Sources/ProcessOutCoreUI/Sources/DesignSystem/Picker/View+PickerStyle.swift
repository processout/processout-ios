//
//  View+PickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO)
    public func pickerStyle(_ style: any POPickerStyle) -> some View {
        environment(\.pickerStyle, style)
    }
}

extension EnvironmentValues {

    @MainActor
    var pickerStyle: any POPickerStyle {
        get { self[Key.self] ?? .radioGroup }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue: (any POPickerStyle)? = nil
    }
}
