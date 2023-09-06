//
//  CustomButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.09.2023.
//

import SwiftUI

extension View {

    /// Sets the style for buttons within this view to a button style with a
    /// custom appearance and standard interaction behavior.
    public func buttonStyle(_ style: POButtonStyle) -> some View {
        buttonStyle(ProcessOutButtonStyle(style: style))
    }

    /// Adds a condition that controls whether button with a `POButtonStyle` should show loading indicator.
    public func buttonLoading(_ isLoading: Bool) -> some View {
        environment(\.isButtonLoading, isLoading)
    }
}

extension EnvironmentValues {

    /// A Boolean value that indicates whether the button associated with this
    /// environment shows loading indicator. Only applicable with `POButtonStyle`.
    ///
    /// The default value is `false`.
    public var isButtonLoading: Bool {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = false
    }
}

private struct ProcessOutButtonStyle: ButtonStyle {

    let style: POButtonStyle

    // MARK: - ButtonStyle

    func makeBody(configuration: Configuration) -> some View {
        // todo(andrii-vysotskyi): support activity indicator
        let currentStyle = stateStyle(isPressed: configuration.isPressed)
        ZStack {
            ActivityIndicatorView()
                .activityIndicatorStyle(style.activityIndicator)
                .opacity(isLoading ? 1 : 0)
            configuration.label
                .textStyle(currentStyle.title, maximumFontSize: Constants.maximumFontSize, relativeTo: .body)
                .opacity(isLoading ? 0 : 1)
        }
        .frame(maxWidth: .infinity, minHeight: Constants.height)
        .background(Color(currentStyle.backgroundColor))
        .environment(\.isEnabled, true)
        .border(style: currentStyle.border)
        .shadow(style: currentStyle.shadow)
        .allowsHitTesting(isEnabled && !isLoading)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let height: CGFloat = 44
        static let maximumFontSize: CGFloat = 28
    }

    // MARK: - Private Properties

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isButtonLoading) private var isLoading

    // MARK: - Private Methods

    private func stateStyle(isPressed: Bool) -> POButtonStateStyle {
        if !isEnabled {
            return style.disabled
        }
        return isPressed ? style.highlighted : style.normal
    }
}
