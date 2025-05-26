//
//  View+TextStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 05.09.2023.
//

import SwiftUI

extension View {

    /// Applies given `style` to text.
    @_spi(PO)
    @available(iOS 14, *)
    @MainActor
    public func textStyle(_ style: POTextStyle) -> some View {
        typography(style.typography)
            .foregroundColor(style.color)
            .environment(\.textStyle, style)
    }

    @_spi(PO)
    @available(iOS 14, *)
    @MainActor
    public func typography(_ typography: POTypography) -> some View {
        modifier(TypographyModifier(typography: typography))
    }
}

@available(iOS 14, *)
@MainActor
private struct TypographyModifier: ViewModifier {

    init(typography: POTypography) {
        self.typography = typography
        _multiplier = .init(wrappedValue: 1, relativeTo: typography.textStyle)
    }

    // MARK: - ViewModifier

    func body(content: Content) -> some View {
        let resolvedFont = self.resolvedFont()
        return content
            .font(Font(resolvedFont))
            .environment(\._lineHeightMultiple, typography.lineHeight / typography.font.lineHeight)
            .modify { content in
                if #available(iOS 16, *) {
                    content.kerning(typography.kerning * multiplier)
                } else {
                    content
                }
            }
    }

    // MARK: - Private Properties

    private let typography: POTypography

    @POBackport.ScaledMetric
    private var multiplier: CGFloat

    @Environment(\.fontFeatures)
    private var fontFeatures

    // MARK: - Private Methods

    private func resolvedFont() -> UIFont {
        typography.font.addingFeatures(fontFeatures).withSize(typography.font.pointSize * multiplier)
    }
}
