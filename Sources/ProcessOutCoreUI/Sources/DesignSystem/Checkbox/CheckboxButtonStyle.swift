//
//  CheckboxButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@available(iOS 14.0, *)
struct CheckboxButtonStyle: ButtonStyle {

    /// Defines whether checkbox is selected.
    let isSelected: Bool

    /// Toggle style.
    let style: POCheckboxToggleStyle

    // MARK: - ButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        ContentView { isInvalid, isEnabled, colorScheme in
            let style = resolveStyle(isInvalid: isInvalid, isEnabled: isEnabled)
            Label(
                title: {
                    configuration.label
                        .textStyle(style.value)
                        .frame(maxWidth: .infinity, alignment: .leading)
                },
                icon: {
                    CheckboxView(isSelected: isSelected, style: style.checkmark)
                }
            )
            .brightness(
                brightnessAdjustment(isPressed: configuration.isPressed, colorScheme: colorScheme)
            )
            .frame(minHeight: 44)
            .contentShape(.rect)
            .animation(.default, value: isSelected)
            .animation(.default, value: isEnabled)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Methods

    private func resolveStyle(isInvalid: Bool, isEnabled: Bool) -> POCheckboxToggleStateStyle {
        if !isEnabled {
            return style.disabled
        }
        if isInvalid {
            return style.error
        }
        if isSelected {
            return style.selected
        }
        return style.normal
    }

    // MARK: - Private Methods

    private func brightnessAdjustment(isPressed: Bool, colorScheme: ColorScheme) -> Double {
        guard isPressed else {
            return 0
        }
        return colorScheme == .dark ? -0.08 : 0.15 // Darken if color is light or brighten otherwise
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isInvalid: Bool, _ isEnabled: Bool, _ colorScheme: ColorScheme) -> Content

    var body: some View {
        content(isInvalid, isEnabled, colorScheme)
    }

    // MARK: - Private Properties

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.colorScheme)
    private var colorScheme
}
