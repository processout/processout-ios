//
//  POCheckboxToggleStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

/// A toggle style that displays a checkbox followed by its label.
@MainActor
@preconcurrency
public struct POCheckboxToggleStyle: ToggleStyle {

    /// Style to use when checkbox is not selected.
    public let normal: POCheckboxToggleStateStyle

    /// Style to use when checkbox becomes highlighted.
    public let highlighted: POCheckboxToggleStateStyle

    /// Style to use when checkbox is selected.
    public let selected: POCheckboxToggleStateStyle

    /// Style to use when checkbox becomes highlighted while selected.
    public let selectedHighlighted: POCheckboxToggleStateStyle

    /// Style to use when checkbox is in error.
    public let error: POCheckboxToggleStateStyle

    /// Style to use when checkbox is disabled.
    public let disabled: POCheckboxToggleStateStyle

    /// Creates style instance.
    public init(
        normal: POCheckboxToggleStateStyle,
        highlighted: POCheckboxToggleStateStyle? = nil,
        selected: POCheckboxToggleStateStyle,
        selectedHighlighted: POCheckboxToggleStateStyle? = nil,
        error: POCheckboxToggleStateStyle,
        disabled: POCheckboxToggleStateStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted ?? normal
        self.selected = selected
        self.selectedHighlighted = selectedHighlighted ?? selected
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
        .buttonStyle(
            CheckboxButtonStyle(
                normal: normal,
                highlighted: highlighted,
                selected: selected,
                selectedHighlighted: selectedHighlighted,
                error: error,
                disabled: disabled
            )
        )
        .controlSelected(configuration.isOn)
    }
}
