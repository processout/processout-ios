//
//  POButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import SwiftUI

/// Defines button style in all possible states.
public struct POButtonStyle: ButtonStyle {

    /// Style for normal state.
    public let normal: POButtonStateStyle

    /// Style for highlighted state.
    public let highlighted: POButtonStateStyle

    /// Style for disabled state.
    public let disabled: POButtonStateStyle

    /// Progress view style. Only used with normal state.
    public let progressView: POProgressViewStyle

    public init(
        normal: POButtonStateStyle,
        highlighted: POButtonStateStyle,
        disabled: POButtonStateStyle,
        progressView: POProgressViewStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.progressView = progressView
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        let currentStyle = stateStyle(isPressed: configuration.isPressed)
        ZStack {
            POProgressView()
                .progressViewStyle(progressView)
                .opacity(isLoading ? 1 : 0)
            configuration.label
                .textStyle(currentStyle.title)
                .multilineTextAlignment(.center)
                .opacity(isLoading ? 0 : 1)
        }
        .padding(Constants.padding)
        .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
        .background(Color(currentStyle.backgroundColor))
        .border(style: currentStyle.border)
        .shadow(style: currentStyle.shadow)
        .allowsHitTesting(isEnabled && !isLoading)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let minHeight: CGFloat = 44
        static let padding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    }

    // MARK: - Private Properties

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isButtonLoading) private var isLoading

    // MARK: - Private Methods

    private func stateStyle(isPressed: Bool) -> POButtonStateStyle {
        if !isEnabled {
            return disabled
        }
        return isPressed ? highlighted : normal
    }
}

extension POButtonStyle {

    /// Default style for primary button.
    @_spi(PO) public static let primary = POButtonStyle(
        normal: .init(
            title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
            border: .clear,
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(resource: .Text.on), typography: .Fixed.button),
            border: .clear,
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
            border: .clear,
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Primary.disabled)
        ),
        progressView: .system(.medium, color: UIColor(resource: .Text.on))
    )

    /// Default style for secondary button.
    @_spi(PO) public static let secondary = POButtonStyle(
        normal: .init(
            title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
            border: .regular(color: UIColor(resource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Secondary.default)
        ),
        highlighted: .init(
            title: .init(color: UIColor(resource: .Text.secondary), typography: .Fixed.button),
            border: .regular(color: UIColor(resource: .Border.default)),
            shadow: .clear,
            backgroundColor: UIColor(resource: .Action.Secondary.pressed)
        ),
        disabled: .init(
            title: .init(color: UIColor(resource: .Text.disabled), typography: .Fixed.button),
            border: .regular(color: UIColor(resource: .Action.Border.disabled)),
            shadow: .clear,
            backgroundColor: .clear
        ),
        progressView: .system(.medium, color: UIColor(resource: .Text.secondary))
    )
}
