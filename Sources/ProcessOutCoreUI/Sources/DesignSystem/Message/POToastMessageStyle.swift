//
//  POToastMessageStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

@available(iOS 14.0, *)
public struct POToastMessageStyle: POMessageViewStyle {

    /// Style for specific severity.
    public struct Severity: Sendable {

        /// Icon image.
        public let icon: Image?

        /// Border style.
        public let border: POBorderStyle

        /// Background color.
        public let backgroundColor: Color

        /// Text style.
        public let text: POTextStyle
    }

    /// Style to apply to message view with **error** severity.
    public let error: Severity

    public init(error: Severity = .error) {
        self.error = error
    }

    // MARK: - POMessageStyle

    public func makeBody(configuration: Configuration) -> some View {
        let style = style(for: configuration.severity)
        Label(
            title: {
                configuration.label.textStyle(style.text)
            },
            icon: {
                style.icon?.foregroundColor(style.text.color)
            }
        )
        .padding(POSpacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(style.backgroundColor)
        .border(style: style.border)
        .backport.geometryGroup()
    }

    // MARK: - Private Methods

    private func style(for severity: POMessageSeverity) -> Severity {
        error // `error` is the only severity for now
    }
}

@available(iOS 14.0, *)
extension POMessageViewStyle where Self == POToastMessageStyle {

    /// Toast message style.
    public static var toast: POToastMessageStyle {
        POToastMessageStyle()
    }
}

@available(iOS 14.0, *)
extension POToastMessageStyle.Severity {

    /// Error style.
    public static let error = Self(
        icon: Image(.info).renderingMode(.template),
        border: .regular(color: Color(.Input.Border.error)),
        backgroundColor: Color(.Surface.error),
        text: POTextStyle(color: Color(.Text.primary), typography: .body2)
    )
}
