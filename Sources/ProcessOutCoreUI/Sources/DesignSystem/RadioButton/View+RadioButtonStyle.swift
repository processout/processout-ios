//
//  View+RadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 08.09.2023.
//

import SwiftUI

extension View {

    public func buttonStyle(_ style: PORadioButtonStyle) -> some View {
        buttonStyle(RadioButtonStyle(style: style))
    }

    public func radioButtonSelected(_ isSelected: Bool) -> some View {
        environment(\.isRadioButtonSelected, isSelected)
    }

    public func radioButtonInError(_ inError: Bool) -> some View {
        environment(\.isRadioButtonInError, inError)
    }
}

extension EnvironmentValues {

    public var isRadioButtonSelected: Bool {
        get { self[SelectionKey.self] }
        set { self[SelectionKey.self] = newValue }
    }

    public var isRadioButtonInError: Bool {
        get { self[ErrorKey.self] }
        set { self[ErrorKey.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct SelectionKey: EnvironmentKey {
        static let defaultValue = false
    }

    private struct ErrorKey: EnvironmentKey {
        static let defaultValue = false
    }
}

private struct RadioButtonStyle: ButtonStyle {

    let style: PORadioButtonStyle

    // MARK: - ButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        let style = currentStyle(isPressed: configuration.isPressed)
        HStack(alignment: .top, spacing: Constants.spacing) {
            ZStack {
                Circle()
                    .fill(Color(style.knob.backgroundColor))
                Circle()
                    .strokeBorder(Color(style.knob.border.color), lineWidth: style.knob.border.width)
                Circle()
                    .fill(Color(style.knob.innerCircleColor))
                    .frame(width: style.knob.innerCircleRadius * 2)
            }
            .frame(width: Constants.knobSize, height: Constants.knobSize)
            .offset(
                y: (knobVerticalOffset(typography: style.value.typography) - Constants.knobSize) / 2
            )
            configuration
                .label
                .textStyle(style.value, relativeTo: .body)
                .frame(minHeight: Constants.knobSize)
        }
        .padding(.vertical, Constants.minimumPadding)
        .frame(minHeight: Constants.height)
        .allowsHitTesting(!isSelected)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minimumPadding: CGFloat = 8
        static let spacing: CGFloat = 8
        static let height: CGFloat = 44
        static let knobSize: CGFloat = 18
    }

    // MARK: - Private Properties

    @Environment(\.isRadioButtonSelected)
    private var isSelected

    @Environment(\.isRadioButtonInError)
    private var isInError

    @ScaledMetricBackport(relativeTo: .body)
    private var contentSizeMultipler: CGFloat = 1

    // MARK: - Private Methods

    private func currentStyle(isPressed: Bool) -> PORadioButtonStateStyle {
        if isSelected {
            return style.selected
        }
        if isPressed {
            return style.highlighted
        }
        if isInError {
            return style.error
        }
        return style.normal
    }

    private func knobVerticalOffset(typography: POTypography) -> CGFloat {
        if typography.adjustsFontForContentSizeCategory {
            return typography.lineHeight * contentSizeMultipler
        }
        return typography.lineHeight
    }
}
