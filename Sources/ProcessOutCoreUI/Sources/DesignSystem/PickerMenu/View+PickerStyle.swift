//
//  View+PickerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 13.10.2023.
//

import SwiftUI

extension View {

    /// Sets the style for picker views within this view.
    @_spi(PO) public func pickerStyle<Style: POPickerStyle>(_ style: Style) -> some View {
        environment(\.pickerStyle, AnyPickerStyle(erasing: style))
    }
}

extension EnvironmentValues {

    var pickerStyle: AnyPickerStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Properties

    private struct Key: EnvironmentKey {
        static let defaultValue = AnyPickerStyle(erasing: .radioGroup)
    }
}
