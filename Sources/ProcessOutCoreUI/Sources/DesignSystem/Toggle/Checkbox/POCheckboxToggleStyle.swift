//
//  POCheckboxToggleStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

/// A toggle style that displays a checkbox followed by its label.
@available(iOS 14, *)
@MainActor
@preconcurrency
public struct POCheckboxToggleStyle: ToggleStyle {

    /// Style to use when checkbox is not selected.
    public let normal: POCheckboxToggleStateStyle

    /// Style to use when checkbox is selected.
    public let selected: POCheckboxToggleStateStyle

    /// Style to use when checkbox is in error.
    public let error: POCheckboxToggleStateStyle

    /// Style to use when checkbox is disabled.
    public let disabled: POCheckboxToggleStateStyle

    /// Creates style instance.
    public init(
        normal: POCheckboxToggleStateStyle,
        selected: POCheckboxToggleStateStyle,
        error: POCheckboxToggleStateStyle,
        disabled: POCheckboxToggleStateStyle
    ) {
        self.normal = normal
        self.selected = selected
        self.error = error
        self.disabled = disabled
    }

    // MARK: - ToggleStyle

    public func makeBody(configuration: Configuration) -> some View {
        Button(
            action: {
                configuration.isOn.toggle()
            },
            label: {
                configuration.label
            }
        )
        .buttonStyle(CheckboxButtonStyle(isSelected: configuration.isOn, style: self))
    }
}
