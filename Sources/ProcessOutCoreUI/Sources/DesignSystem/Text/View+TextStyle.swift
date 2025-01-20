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
    @_spi(PO)
    @available(iOS 14, *)
    @MainActor
    public func textStyle(_ style: POTextStyle, addPadding: Bool = true) -> some View {
        typography(style.typography, addPadding: addPadding)
            .foregroundColor(style.color)
            .environment(\.textStyle, style)
    }

    @_spi(PO)
    @available(iOS 14, *)
    @MainActor
    public func typography(_ typography: POTypography, addPadding: Bool = true) -> some View {
        modifier(TypographyModifier(typography: typography, addPadding: addPadding))
    }
}

@available(iOS 14, *)
@MainActor
private struct TypographyModifier: ViewModifier {

    init(typography: POTypography, addPadding: Bool) {
        self.typography = typography
        self.addPadding = addPadding
        _multiplier = .init(wrappedValue: 1, relativeTo: typography.textStyle)
    }

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        let resolvedFont = self.resolvedFont()
        let lineSpacing = (typography.lineHeight / typography.font.lineHeight - 1) * resolvedFont.lineHeight
        return content
            .font(Font(resolvedFont))
            .lineSpacing(lineSpacing)
            .modify { content in
                if #available(iOS 16, *) {
                    content.kerning(typography.kerning)
                } else {
                    content
                }
            }
            .padding(.vertical, addPadding ? lineSpacing / 2 : 0)
    }

    // MARK: - Private Properties

    private let typography: POTypography
    private let addPadding: Bool

    @POBackport.ScaledMetric
    private var multiplier: CGFloat

    @Environment(\.fontFeatures)
    private var fontFeatures

    // MARK: - Private Methods

    private func resolvedFont() -> UIFont {
        typography.font.addingFeatures(fontFeatures).withSize(typography.font.pointSize * multiplier)
    }
}
