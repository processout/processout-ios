//
//  View+Typography.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 04.09.2023.
//

import SwiftUI

extension View {

    /// - Parameters:
    ///   - typography: The typography of the text.
    ///   - maximumFontSize: The maximum point size allowed for the font. Use this value to constrain the font to
    ///   the specified size when your interface cannot accommodate text that is any larger.
    ///   - textStyle: Constants that describe the preferred styles for fonts.
    public func typography(
        _ typography: POTypography,
        maximumFontSize: CGFloat = .greatestFiniteMagnitude,
        relativeTo textStyle: UIFont.TextStyle = .body
    ) -> some View {
        modifier(TypographyModifier(typography: typography, maximumFontSize: maximumFontSize, textStyle: textStyle))
    }
}

private struct TypographyModifier: ViewModifier {

    init(typography: POTypography, maximumFontSize: CGFloat, textStyle: UIFont.TextStyle) {
        self.typography = typography
        self.maximumFontSize = maximumFontSize
        _multipler = .init(wrappedValue: 1, relativeTo: textStyle)
    }

    func body(content: Content) -> some View {
        let font = createFont()
        let lineSpacing = (typography.lineHeight / typography.font.lineHeight - 1) * font.lineHeight
        return content
            .font(Font(font))
            .modify { content in
                if let tracking = typography.tracking, #available(iOS 16.0, *) {
                    content.tracking(tracking)
                }
                content
            }
            .lineSpacing(lineSpacing)
            .padding(.vertical, lineSpacing / 2)
    }

    // MARK: - Private Properties

    private let typography: POTypography
    private let maximumFontSize: CGFloat

    @ScaledMetricBackport
    private var multipler: CGFloat

    // MARK: - Private Methods

    private func createFont() -> UIFont {
        var font = typography.font
        if typography.adjustsFontForContentSizeCategory {
            font = font.withSize(typography.font.pointSize * multipler)
        }
        if font.pointSize > maximumFontSize {
            font = font.withSize(maximumFontSize)
        }
        return font
    }
}
