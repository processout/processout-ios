//
//  CheckboxButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

@available(iOS 14, *)
@MainActor
struct CheckboxButtonStyle: ButtonStyle {

    /// Specific state styles.
    let normal, highlighted, selected, selectedHighlighted, error, disabled: POCheckboxToggleStateStyle

    // MARK: - ButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        ContentView(
            normal: normal,
            highlighted: highlighted,
            selected: selected,
            selectedHighlighted: selectedHighlighted,
            error: error,
            disabled: disabled,
            configuration: configuration
        )
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.
@available(iOS 14, *)
@MainActor
private struct ContentView: View {

    /// Specific state styles.
    let normal, highlighted, selected, selectedHighlighted, error, disabled: POCheckboxToggleStateStyle

    /// Button configuration
    let configuration: ButtonStyleConfiguration

    // MARK: - View

    var body: some View {
        let style = resolvedStyle()
        Label(
            title: {
                configuration.label
                    .textStyle(style.value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            },
            icon: {
                CheckboxToggleCheckmarkView(style: style.checkmark, textStyle: style.value.typography.textStyle)
            }
        )
        .backport.background {
            style.backgroundColor
                .cornerRadius(POSpacing.extraSmall)
                .padding(Constants.backgroundPadding)
        }
        .contentShape(.standardHittableRect)
        .animation(.default, value: isSelected)
        .animation(.default, value: isEnabled)
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let backgroundPadding = EdgeInsets(horizontal: -10, vertical: -11)
    }

    // MARK: - Private Properties

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.poControlSelected)
    private var isSelected

    @Environment(\.colorScheme)
    private var colorScheme

    // MARK: - Private Methods

    private func resolvedStyle() -> POCheckboxToggleStateStyle {
        if !isEnabled {
            return disabled
        }
        if configuration.isPressed {
            if isSelected {
                return selectedHighlighted
            }
            return highlighted
        }
        if isInvalid {
            return error
        }
        if isSelected {
            return selected
        }
        return normal
    }
}
