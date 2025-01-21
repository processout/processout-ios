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
        StateContentView(isSelected: isSelected, style: resolvedStyle(), configuration: configuration)
            .contentShape(.standardHittableRect)
            .animation(.default, value: isSelected)
            .animation(.default, value: isEnabled)
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.poControlSelected)
    private var isSelected

    @Environment(\.isControlInvalid)
    private var isInvalid

    @Environment(\.isEnabled)
    private var isEnabled

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
}

@available(iOS 14, *)
@MainActor
private struct StateContentView: View {

    init(isSelected: Bool, style: PORadioButtonStateStyle, configuration: ButtonStyleConfiguration) {
        self.isSelected = isSelected
        self.style = style
        self.configuration = configuration
        self._knobScale = .init(wrappedValue: 1, relativeTo: style.value.typography.textStyle)
    }

    // MARK: - View

    var body: some View {
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
                        .frame(width: isSelected ? style.knob.innerCircleRadius * 2 * knobScale : 0)
                }
                .frame(width: Constants.knobSize * knobScale, height: Constants.knobSize * knobScale)
            }
        )
        .backport.background {
            style.backgroundColor
                .cornerRadius(POSpacing.extraSmall)
                .padding(Constants.backgroundPadding)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let knobSize: CGFloat = 22
        static let backgroundPadding = EdgeInsets(horizontal: -10, vertical: -12)
    }

    // MARK: - Private Properties

    private let isSelected: Bool, style: PORadioButtonStateStyle, configuration: ButtonStyleConfiguration

    @POBackport.ScaledMetric
    private var knobScale: CGFloat
}

@available(iOS 18, *)
#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var isOn = false
    Button {
        isOn = true
    } label: {
        Label {
            Text("Label")
        } icon: {
            EmptyView()
        }
    }
    .buttonStyle(.radio)
    .controlSelected(isOn)
    .padding()
}
