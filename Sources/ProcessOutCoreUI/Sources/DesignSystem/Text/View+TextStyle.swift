//
//  View+TextStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.09.2023.
//

import SwiftUI

extension View {

    /// Applies given `style` to text.
    ///
    /// - NOTE: When `addPadding` is set to true this method has a cumulative effect.
    @available(iOS 14.0, *)
    @_spi(PO)
    public func textStyle(_ style: POTextStyle, addPadding: Bool = true) -> some View {
        modifier(ContentModifier(style: style, addPadding: addPadding))
    }
}

@available(iOS 14.0, *)
extension EnvironmentValues {

    var textStyle: POTextStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POTextStyle(color: Color(.Text.primary), typography: .body2)
    }
}

@available(iOS 14.0, *)
private struct ContentModifier: ViewModifier {

    init(style: POTextStyle, addPadding: Bool) {
        self.style = style
        self.addPadding = addPadding
        _multiplier = .init(wrappedValue: 1, relativeTo: style.typography.textStyle)
    }

    func body(content: Content) -> some View {
        let font = style.typography.font
            .addingFeatures(fontFeatures)
            .withSize(style.typography.font.pointSize * multiplier)
        let lineSpacing = (style.typography.lineHeight / style.typography.font.lineHeight - 1) * font.lineHeight
        return content
            .font(Font(font))
            .lineSpacing(lineSpacing)
            .padding(.vertical, addPadding ? lineSpacing / 2 : 0)
            .foregroundColor(style.color)
            .environment(\.textStyle, style)
    }

    // MARK: - Private Properties

    private let style: POTextStyle
    private let addPadding: Bool

    @POBackport.ScaledMetric
    private var multiplier: CGFloat

    @Environment(\.fontFeatures)
    private var fontFeatures
}
