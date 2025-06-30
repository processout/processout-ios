//
//  POStepProgressViewStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 12.04.2025.
//

import SwiftUI

// swiftlint:disable nesting

/// Single step progress view style.
@available(iOS 14.0, *)
public struct POStepProgressViewStyle: ProgressViewStyle {

    /// Defines progress view style resolved in a specific state.
    public struct Resolved {

        /// Label style.
        public let label: POTextStyle

        /// Current value label text style.
        public let currentValueLabel: POTextStyle

        /// Icon style.
        public let icon: Icon

        public init(label: POTextStyle, currentValueLabel: POTextStyle, icon: Icon) {
            self.label = label
            self.currentValueLabel = currentValueLabel
            self.icon = icon
        }
    }

    /// Defines icon style properties.
    public struct Icon: Sendable {

        public struct Checkmark: Sendable {

            /// Checkmark color.
            public let color: Color

            /// Checkmark width.
            public let width: CGFloat

            public init(color: Color, width: CGFloat) {
                self.color = color
                self.width = width
            }
        }

        public struct Halo: Sendable {

            /// Halo color.
            public let color: Color

            /// Halo width.
            public let width: CGFloat

            public init(color: Color, width: CGFloat) {
                self.color = color
                self.width = width
            }
        }

        /// Checkmark style..
        public let checkmark: Checkmark?

        /// Background color.
        public let backgroundColor: Color

        /// Border style.
        public let border: POBorderStyle

        /// Icon halo.
        public let halo: Halo?

        /// Creates checkmark style instance.
        public init(checkmark: Checkmark?, backgroundColor: Color, border: POBorderStyle, halo: Halo?) {
            self.checkmark = checkmark
            self.backgroundColor = backgroundColor
            self.border = border
            self.halo = halo
        }
    }

    /// Specific state style.
    public let notStarted: Resolved, started: Resolved, completed: Resolved

    /// Creates style instance.
    public init(notStarted: Resolved, started: Resolved, completed: Resolved) {
        self.notStarted = notStarted
        self.started = started
        self.completed = completed
    }

    // MARK: - ProgressViewStyle

    public func makeBody(configuration: Configuration) -> some View {
        StyleContent(style: self, configuration: configuration)
    }
}

// swiftlint:enable nesting

@available(iOS 14.0, *)
private struct StyleContent: View {

    let style: POStepProgressViewStyle, configuration: ProgressViewStyleConfiguration

    // MARK: - View

    var body: some View {
        let resolvedStyle = if configuration.fractionCompleted == 0.0 {
            style.notStarted
        } else if configuration.fractionCompleted == 1.0 {
            style.completed
        } else {
            style.started
        }
        HStack(spacing: POSpacing.medium) {
            makeIcon(style: resolvedStyle.icon)
                .anchorPreference(
                    key: MultistepProgressGroupStylePreferenceKey.self,
                    value: .bounds,
                    transform: { anchor in
                        [.init(fractionCompleted: configuration.fractionCompleted, connectorAnchor: anchor)]
                    }
                )
            makeContent(style: resolvedStyle)
        }
        .animation(.default, value: configuration.fractionCompleted)
    }

    // MARK: - Private Properties

    @State
    private var haloWidth: CGFloat = 0

    // MARK: - Icon

    @ViewBuilder
    private func makeIcon(style: POStepProgressViewStyle.Icon) -> some View {
        ZStack {
            let iconSize: CGFloat = 24
            Circle()
                .foregroundColor(style.backgroundColor)
                .border(style: style.border)
                .frame(width: iconSize, height: iconSize)
            if let checkmarkStyle = style.checkmark {
                let checkmarkScale: CGFloat = 0.75
                CheckmarkShape()
                    .stroke(
                        checkmarkStyle.color,
                        style: StrokeStyle(lineWidth: checkmarkStyle.width, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: iconSize * checkmarkScale, height: iconSize * checkmarkScale)
            }
        }
        .backport.background {
            if let style = style.halo {
                makeIconHalo(style: style)
            }
        }
        .backport.geometryGroup()
    }

    @ViewBuilder
    private func makeIconHalo(style: POStepProgressViewStyle.Icon.Halo) -> some View {
        Circle()
            .stroke(style.color, lineWidth: haloWidth)
            .onAppear {
                withAnimation(nil) {
                    haloWidth = 0
                }
                withAnimation(.easeInOut(duration: 0.75).repeatForever(autoreverses: true)) {
                    haloWidth = style.width
                }
            }
            .padding(-haloWidth / 2)
    }

    // MARK: - Content

    @ViewBuilder
    private func makeContent(style: POStepProgressViewStyle.Resolved) -> some View {
        VStack(alignment: .leading, spacing: POSpacing.extraSmall) {
            configuration.label?
                .textStyle(style.label)
            configuration.currentValueLabel?
                .textStyle(style.currentValueLabel)
        }
    }
}

@available(iOS 16.0, *)
#Preview {
    ProgressView(
        value: 0.5,
        label: {
            Text("Label")
        },
        currentValueLabel: {
            Text("Current value")
        }
    )
    .progressViewStyle(.poStep)
}
