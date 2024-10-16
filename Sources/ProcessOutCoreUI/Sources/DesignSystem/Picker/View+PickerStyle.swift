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
    @available(iOS 14, *)
    public func pickerStyle<Style: POPickerStyle>(_ style: Style) -> some View {
        environment(\.pickerStyle, style)
    }
}

@available(iOS 14, *)
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
