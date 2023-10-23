//
//  PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import SwiftUI

/// Describes radio button style in different states.
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

    /// Creates style instance.
    public init(
        normal: PORadioButtonStateStyle,
        selected: PORadioButtonStateStyle,
        highlighted: PORadioButtonStateStyle,
        error: PORadioButtonStateStyle
    ) {
        self.normal = normal
        self.selected = selected
        self.highlighted = highlighted
        self.error = error
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        ContentView { isSelected, isInvalid, sizeMultipler in
            let style = currentStyle(isSelected: isSelected, isInvalid: isInvalid, isPressed: configuration.isPressed)
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
                    y: knobVerticalOffset(typography: style.value.typography, sizeMultipler: sizeMultipler)
                )
                configuration
                    .label
                    .textStyle(style.value)
                    .frame(minHeight: Constants.knobSize)
            }
            .padding(.vertical, Constants.minVerticalPadding)
            .frame(maxWidth: .infinity, minHeight: Constants.minHeight, alignment: .leading)
            .animation(.default, value: isSelected)
            .contentShape(.rect)
            .allowsHitTesting(!isSelected)
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minVerticalPadding: CGFloat = 4
        static let spacing: CGFloat = 8
        static let minHeight: CGFloat = 44
        static let knobSize: CGFloat = 18
    }

    // MARK: - Private Methods

    private func currentStyle(isSelected: Bool, isInvalid: Bool, isPressed: Bool) -> PORadioButtonStateStyle {
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

    private func knobVerticalOffset(
        typography: POTypography, sizeMultipler: POBackport<Any>.ScaledMetric<CGFloat>
    ) -> CGFloat {
        let lineHeight = typography.lineHeight * sizeMultipler.value(relativeTo: typography.textStyle)
        return (lineHeight - Constants.knobSize) / 2
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isSelected: Bool, _ isInvalid: Bool, POBackport<Any>.ScaledMetric<CGFloat>) -> Content

    var body: some View {
        content(isSelected, isInvalid, _contentSizeMultipler)
    }

    // MARK: - Private Properties

    @Environment(\.isRadioButtonSelected) private var isSelected
    @Environment(\.isControlInvalid) private var isInvalid

    @POBackport.ScaledMetric
    private var contentSizeMultipler: CGFloat = 1
}
