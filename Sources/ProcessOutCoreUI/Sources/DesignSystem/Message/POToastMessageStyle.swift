//
//  POToastMessageStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 03.06.2024.
//

import SwiftUI

@available(iOS 14, *)
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

        public init(icon: Image?, border: POBorderStyle, backgroundColor: Color, text: POTextStyle) {
            self.icon = icon
            self.border = border
            self.backgroundColor = backgroundColor
            self.text = text
        }
    }

    /// Style to apply to message view with **error** severity.
    public let error: Severity

    public init(error: Severity) {
        self.error = error
    }

    @available(*, deprecated)
    public init() {
        self.error = .error
    }

    // MARK: - POMessageStyle

    public func makeBody(configuration: Configuration) -> some View {
        let style = style(for: configuration.severity)
        Label(
            title: {
                configuration.label
            },
            icon: {
                style.icon
            }
        )
        .textStyle(style.text)
        .padding(
            .init(horizontal: POSpacing.space12, vertical: POSpacing.space8)
        )
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

@available(iOS 14, *)
extension POMessageViewStyle where Self == POToastMessageStyle {

    /// Toast message style.
    public static var toast: POToastMessageStyle {
        POToastMessageStyle(error: .error)
    }
}

@available(iOS 14, *)
extension POToastMessageStyle.Severity {

    /// Error style.
    public static let error = Self(
        icon: Image(poResource: .info).renderingMode(.template),
        border: .toast(color: Color.Toast.border),
        backgroundColor: Color.Toast.background,
        text: POTextStyle(color: Color.Toast.text, typography: .Text.s14(weight: .medium))
    )
}

@available(iOS 14, *)
#Preview {
    POMessageView(message: .init(id: "id", text: "Messeeee e e e e eage", severity: .error))
        .messageViewStyle(.toast)
        .padding()
}
