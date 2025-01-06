//
//  POButtonStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 22.11.2022.
//

import SwiftUI

/// Defines button style in all possible states.
@available(iOS 14, *)
@MainActor
@preconcurrency
public struct POButtonStyle<ProgressStyle: ProgressViewStyle>: ButtonStyle {

    /// Style for normal state.
    public let normal: POButtonStateStyle

    /// Style to use when button is selected.
    public let selected: POButtonStateStyle

    /// Style for highlighted state.
    public let highlighted: POButtonStateStyle

    /// Style for disabled state.
    public let disabled: POButtonStateStyle

    /// Progress view style. Only used with normal state.
    public let progressStyle: ProgressStyle

    /// Boolean value indicating whether content is padded.
    public let isContentPadded: Bool

    public init(
        normal: POButtonStateStyle,
        selected: POButtonStateStyle? = nil,
        highlighted: POButtonStateStyle,
        disabled: POButtonStateStyle,
        progressStyle: ProgressStyle,
        isContentPadded: Bool = true
    ) {
        self.normal = normal
        self.selected = selected ?? normal
        self.highlighted = highlighted
        self.disabled = disabled
        self.progressStyle = progressStyle
        self.isContentPadded = isContentPadded
    }

    // MARK: - ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        ButtonStyleBox(
            normal: normal,
            selected: selected,
            highlighted: highlighted,
            disabled: disabled,
            progressStyle: progressStyle,
            isContentPadded: isContentPadded,
            configuration: configuration
        )
    }
}

// Environments may not be propagated directly to ButtonStyle. Workaround is
// to wrap content into additional view and use environments as usual.
@available(iOS 14.0, *)
@MainActor
private struct ButtonStyleBox<ProgressStyle: ProgressViewStyle>: View {

    /// State styles.
    let normal, selected, highlighted, disabled: POButtonStateStyle

    /// Progress view style.
    let progressStyle: ProgressStyle

    /// Indicates whether content is padded.
    let isContentPadded: Bool

    /// Button style configuration.
    let configuration: ButtonStyleConfiguration

    // MARK: - View

    var body: some View {
        let currentStyle = stateStyle(isPressed: configuration.isPressed)
        configuration.label
            .labelStyle(ButtonLabelStyle(titleStyle: currentStyle.title))
            .opacity(
                isLoading ? 0 : 1
            )
            .backport.overlay {
                if isLoading {
                    ProgressView().progressViewStyle(progressStyle)
                }
            }
            .modify(when: isContentPadded) { content in
                content
                    .padding(POSpacing.small)
                    .frame(minWidth: minSize, maxWidth: maxWidth, minHeight: minSize)
            }
            .backport.background {
                currentStyle.backgroundColor
                    .border(style: currentStyle.border)
                    .shadow(style: currentStyle.shadow)
                    .modify(when: !isContentPadded) { content in
                        content
                            .frame(minWidth: minSize, minHeight: minSize)
                            .padding(-POSpacing.small)
                    }
            }
            .contentShape(.standardHittableRect)
            .animation(.default, value: isLoading)
            .animation(.default, value: isEnabled)
            .allowsHitTesting(isEnabled && !isLoading)
            .backport.geometryGroup()
    }

    // MARK: - Private Properties

    @Environment(\.poControlSelected)
    private var isSelected

    @Environment(\.isEnabled)
    private var isEnabled

    @Environment(\.isButtonLoading)
    private var isLoading

    @Environment(\.poControlSize)
    private var controlSize

    @Environment(\.poControlWidth)
    private var controlWidth

    // MARK: - Private Methods

    private func stateStyle(isPressed: Bool) -> POButtonStateStyle {
        if isLoading {
            return normal
        }
        if !isEnabled {
            return disabled
        }
        if isPressed {
            return highlighted
        }
        if isSelected {
            return selected
        }
        return normal
    }

    private var minSize: CGFloat {
        let sizes: [POControlSize: CGFloat] = [.small: 32, .regular: 44]
        return sizes[controlSize]! // swiftlint:disable:this force_unwrapping
    }

    private var maxWidth: CGFloat? {
        let widths: [POControlWidth: CGFloat] = [.expanded: .infinity]
        return widths[controlWidth]
    }
}
