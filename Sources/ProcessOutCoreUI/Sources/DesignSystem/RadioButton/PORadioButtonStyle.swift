//
//  PORadioButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 06.06.2023.
//

import SwiftUI

/// Describes radio button style in different states.
@available(iOS 14, *)
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
        ContentView { isSelected, isInvalid in
            let style = currentStyle(isSelected: isSelected, isInvalid: isInvalid, isPressed: configuration.isPressed)
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
        }
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let knobSize: CGFloat = 24
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
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isSelected: Bool, _ isInvalid: Bool) -> Content

    var body: some View {
        content(isSelected, isInvalid)
    }

    // MARK: - Private Properties

    @Environment(\.isRadioButtonSelected)
    private var isSelected

    @Environment(\.isControlInvalid)
    private var isInvalid
}
