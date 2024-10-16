//
//  PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import SwiftUI

/// Describes radio button style in different states.
@available(iOS 14, *)
@MainActor
@preconcurrency
public struct PORadioButtonStyle: ButtonStyle {

    /// Style to use when radio button is in default state ie enabled and not selected.
    public let normal: PORadioButtonStateStyle

    /// Style to use when radio button is selected.
    public let selected: PORadioButtonStateStyle

    /// Style to use when radio button is highlighted. Note that radio can transition
    /// to this state when already selected.
    public let highlighted: PORadioButtonStateStyle

    /// Style to use when radio button is in error state.
    public let error: PORadioButtonStateStyle

    /// Style to use when radio button is disabled.
    public let disabled: PORadioButtonStateStyle

    /// Creates style instance.
    public init(
        normal: PORadioButtonStateStyle,
        selected: PORadioButtonStateStyle,
        highlighted: PORadioButtonStateStyle,
        error: PORadioButtonStateStyle,
        disabled: PORadioButtonStateStyle? = nil
    ) {
        self.normal = normal
        self.selected = selected
        self.highlighted = highlighted
        self.error = error
        self.disabled = disabled ?? normal
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        ContentView { isSelected, isInvalid, isEnabled in
            let style = resolveStyle(
                isSelected: isSelected, isInvalid: isInvalid, isPressed: configuration.isPressed, isEnabled: isEnabled
            )
            Label(
                title: {
                    configuration.label
                        .textStyle(style.value, addPadding: false)
                        .frame(maxWidth: .infinity, alignment: .leading)
                },
                icon: {
                    ZStack {
                        Circle()
                            .fill(style.knob.backgroundColor)
                        Circle()
                            .strokeBorder(style.knob.border.color, lineWidth: style.knob.border.width)
                        Circle()
                            .fill(style.knob.innerCircleColor)
                            .frame(width: style.knob.innerCircleRadius * 2)
                    }
                    .frame(width: Constants.knobSize, height: Constants.knobSize)
                }
            )
            .animation(.default, value: isSelected)
            .animation(.default, value: isEnabled)
        }
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let knobSize: CGFloat = 22
    }

    // MARK: - Private Methods

    private func resolveStyle(
        isSelected: Bool, isInvalid: Bool, isPressed: Bool, isEnabled: Bool
    ) -> PORadioButtonStateStyle {
        if !isEnabled {
            return disabled
        }
        if isSelected {
            return selected
        }
        if isPressed {
            return highlighted
        }
        if isInvalid {
            return error
        }
        return normal
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isSelected: Bool, _ isInvalid: Bool, _ isEnabled: Bool) -> Content

    var body: some View {
        content(isSelected, isInvalid, isEnabled)
    }

    // MARK: - Private Properties

    @Environment(\.isRadioButtonSelected)
    private var isSelected

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.isEnabled)
    private var isEnabled
}
