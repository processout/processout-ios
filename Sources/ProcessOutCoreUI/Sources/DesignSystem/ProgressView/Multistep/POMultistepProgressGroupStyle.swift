//
//  POMultistepProgressGroupBoxStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.04.2025.
//

import SwiftUI

// swiftlint:disable nesting

public struct POMultistepProgressGroupBoxStyle: GroupBoxStyle {

    public struct Connector {

        /// Resolved connector style.
        public struct Resolved {

            /// Stroke color.
            public let strokeColor: Color

            /// Stroke style.
            public let strokeStyle: StrokeStyle

            public init(strokeColor: Color, strokeStyle: StrokeStyle) {
                self.strokeColor = strokeColor
                self.strokeStyle = strokeStyle
            }
        }

        /// Style to apply when connecting two completed progress views.
        public let fromCompletedToCompleted: Resolved?

        /// Style to apply when connecting completed progress view with any other progress view.
        public let fromCompletedToAny: Resolved?

        /// Default style.
        public let `default`: Resolved

        public init(fromCompletedToCompleted: Resolved?, fromCompletedToAny: Resolved?, `default`: Resolved) {
            self.fromCompletedToCompleted = fromCompletedToCompleted
            self.fromCompletedToAny = fromCompletedToAny
            self.default = `default`
        }
    }

    /// Connector styles.
    public let connector: Connector

    public init(connector: Connector) {
        self.connector = connector
    }

    // MARK: - GroupBoxStyle

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: POSpacing.space28) {
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .backgroundPreferenceValue(MultistepProgressGroupStylePreferenceKey.self) { preferences in
            makeConnectorsBody(preferences: preferences)
        }
    }

    // MARK: - Private Properties

    @Namespace
    private var connectorsNamespace

    // MARK: - Connector

    @ViewBuilder
    private func makeConnectorsBody(preferences: MultistepProgressGroupStylePreferenceKey.Value) -> some View {
        GeometryReader { geometry in
            let pairedPreferences = Array(
                zip(preferences, preferences.dropFirst()).enumerated()
            )
            ForEach(pairedPreferences, id: \.offset) { offset, preferences in
                let connectorStyle = resolvedConnectorStyle(
                    sourceView: preferences.0, targetView: preferences.1
                )
                connectorPath(
                    from: geometry[preferences.0.connectorAnchor], to: geometry[preferences.1.connectorAnchor]
                )
                .stroke(connectorStyle.strokeColor, style: connectorStyle.strokeStyle)
                .id(connectorStyle.strokeStyle.dash)
                .matchedGeometryEffect(id: offset, in: connectorsNamespace)
            }
        }
    }

    private func connectorPath(from sourceRect: CGRect, to targetRect: CGRect) -> Path {
        Path { path in
            path.move(
                to: Geometry.radialProjection(
                    center: sourceRect.center,
                    radius: Geometry.circleRadius(circumscribedAround: sourceRect),
                    towards: targetRect.center
                )
            )
            path.addLine(
                to: Geometry.radialProjection(
                    center: targetRect.center,
                    radius: Geometry.circleRadius(circumscribedAround: targetRect),
                    towards: sourceRect.center
                )
            )
        }
    }

    private func resolvedConnectorStyle(
        sourceView: MultistepProgressGroupStylePreferenceKey.ProgressViewProxy,
        targetView: MultistepProgressGroupStylePreferenceKey.ProgressViewProxy
    ) -> Connector.Resolved {
        if sourceView.fractionCompleted == 1.0 {
            if targetView.fractionCompleted == 1.0 {
                return connector.fromCompletedToCompleted ?? connector.default
            }
            return connector.fromCompletedToAny ?? connector.default
        }
        return connector.default
    }
}

// swiftlint:enable nesting

@available(iOS 16.0, *)
#Preview {
    GroupBox {
        Group {
            ProgressView("Step 1", value: 1)
            ProgressView("Step 2", value: 1)
            ProgressView(
                value: 0.5,
                label: {
                    Text("Step 3")
                },
                currentValueLabel: {
                    Text("Current value")
                }
            )
            ProgressView("Step 4", value: 0)
        }
        .progressViewStyle(.poStep)
    }
    .groupBoxStyle(.poMultistepProgress)
    .padding()
}
