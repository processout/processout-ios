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

    /// Style to use when radio button is highlighted. Note that radio can't transition
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
        ContentView(
            normal: normal,
            selected: selected,
            highlighted: highlighted,
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

    /// Specific states style.
    let normal, selected, highlighted, error, disabled: PORadioButtonStateStyle

    /// Button configuration.
    let configuration: ButtonStyleConfiguration

    // MARK: - View

    var body: some View {
        let geometry = self.geometry
        let style = resolvedStyle()
        Label(
            title: {
                configuration.label
                    .textStyle(style.value)
                    .frame(maxWidth: .infinity, alignment: .leading)
            },
            icon: {
                RadioButtonKnobView(style: style.knob, textStyle: style.value.typography.textStyle)
            }
        )
        .padding(geometry.padding)
        .frame(minHeight: geometry.minHeight)
        .backport.background {
            style.backgroundColor
                .cornerRadius(POSpacing.extraSmall)
                .padding(geometry.backgroundInsets)
        }
        .contentShape(.standardHittableRect)
        .animation(.default, value: isSelected)
        .animation(.default, value: isEnabled)
        .backport.geometryGroup()
    }

    // MARK: - Private Nested Types

    private struct Geometry {
        let padding: CGFloat
        let minHeight: CGFloat?
        let backgroundInsets: EdgeInsets
    }

    // MARK: - Private Properties

    @Environment(\.poControlSelected)
    private var isSelected

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.poControlSize)
    private var controlSize

    // MARK: - Private Methods

    private func resolvedStyle() -> PORadioButtonStateStyle {
        if !isEnabled {
            return disabled
        }
        if isSelected {
            if isInvalid {
                return error
            }
            return selected
        }
        if configuration.isPressed {
            return highlighted
        }
        if isInvalid {
            return error
        }
        return normal
    }

    private var geometry: Geometry {
        switch controlSize {
        case .regular:
            return .init(
                padding: POSpacing.space12,
                minHeight: 48,
                backgroundInsets: EdgeInsets()
            )
        case .small:
            return .init(padding: 0, minHeight: nil, backgroundInsets: .init(horizontal: -10, vertical: -11))
        }
    }
}

@available(iOS 14, *)
#Preview {
    VStack(spacing: 2) {
        Button("Radio Button") { }
        Button("Radio Button") { }
    }
    .buttonStyle(PORadioButtonStyle.radio)
    .padding()
    .backport.poControlSize(.small)
}
