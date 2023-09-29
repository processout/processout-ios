//
//  Text+Style.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.09.2023.
//

import SwiftUI

extension View {

    /// Applies given `style` to text.
    ///
    /// - NOTE: When `addPadding` is set to true this method has a cumulative effect.
    public func textStyle(_ style: POTextStyle, addPadding: Bool = true) -> some View {
        modifier(ContentModifier(style: style, addPadding: addPadding))
    }
}

extension EnvironmentValues {

    var textStyle: POTextStyle {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }

    // MARK: - Private Nested Types

    private struct Key: EnvironmentKey {
        static let defaultValue = POTextStyle(color: UIColor(resource: .Text.primary), typography: .Fixed.body)
    }
}

private struct ContentModifier: ViewModifier {

    init(style: POTextStyle, addPadding: Bool) {
        self.style = style
        self.addPadding = addPadding
        _multipler = .init(wrappedValue: 1, relativeTo: style.typography.textStyle)
    }

    func body(content: Content) -> some View {
        let font = style.typography.font.withSize(style.typography.font.pointSize * multipler)
        let lineSpacing = (style.typography.lineHeight / style.typography.font.lineHeight - 1) * font.lineHeight
        return content
            .font(Font(font))
            .lineSpacing(lineSpacing)
            .padding(.vertical, addPadding ? lineSpacing / 2 : 0)
            .foregroundColor(Color(style.color))
            .environment(\.textStyle, style)
    }

    // MARK: - Private Properties

    private let style: POTextStyle
    private let addPadding: Bool

    @ScaledMetricBackport
    private var multipler: CGFloat
}
