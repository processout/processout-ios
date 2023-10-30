//
//  POButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import SwiftUI

/// Defines button style in all possible states.
public struct POButtonStyle<ProgressStyle: ProgressViewStyle>: ButtonStyle {

    /// Style for normal state.
    public let normal: POButtonStateStyle

    /// Style for highlighted state.
    public let highlighted: POButtonStateStyle

    /// Style for disabled state.
    public let disabled: POButtonStateStyle

    /// Progress view style. Only used with normal state.
    public let progressView: ProgressStyle

    public init(
        normal: POButtonStateStyle,
        highlighted: POButtonStateStyle,
        disabled: POButtonStateStyle,
        progressView: ProgressStyle
    ) {
        self.normal = normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.progressView = progressView
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        ContentView { isEnabled, isLoading in
            let currentStyle = stateStyle(
                isEnabled: isEnabled, isLoading: isLoading, isPressed: configuration.isPressed
            )
            ZStack {
                ProgressView()
                    .progressViewStyle(progressView)
                    .opacity(isLoading ? 1 : 0)
                configuration.label
                    .textStyle(currentStyle.title)
                    .multilineTextAlignment(.center)
                    .opacity(isLoading ? 0 : 1)
            }
            .padding(Constants.padding)
            .frame(maxWidth: .infinity, minHeight: Constants.minHeight)
            .background(currentStyle.backgroundColor)
            .border(style: currentStyle.border)
            .shadow(style: currentStyle.shadow)
            .backport.geometryGroup()
            .contentShape(.rect)
            .animation(.default, value: isLoading)
            .animation(.default, value: isEnabled)
            .allowsHitTesting(isEnabled && !isLoading)
        }
    }

    // MARK: - Private Methods

    private func stateStyle(isEnabled: Bool, isLoading: Bool, isPressed: Bool) -> POButtonStateStyle {
        if isLoading {
            return normal
        }
        if !isEnabled {
            return disabled
        }
        return isPressed ? highlighted : normal
    }
}

// Environments are not propagated directly to ButtonStyle in any iOS before 14.5 workaround is
// to wrap content into additional view and extract them.
private struct ContentView<Content: View>: View {

    @ViewBuilder
    let content: (_ isEnabled: Bool, _ isLoading: Bool) -> Content

    var body: some View {
        content(isEnabled, isLoading)
    }

    // MARK: - Private Properties

    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.isButtonLoading) private var isLoading
}

private enum Constants {
    static let minHeight: CGFloat = 44
    static let padding = EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
}
