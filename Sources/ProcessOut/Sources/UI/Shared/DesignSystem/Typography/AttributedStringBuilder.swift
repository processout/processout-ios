//
//  AttributedStringBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

struct AttributedStringBuilder {

    enum Text {
        case plain(String), markdown(String)
    }

    /// The text alignment of the paragraph.
    var alignment: NSTextAlignment = .natural

    /// The mode for breaking lines in the paragraph.
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail

    /// The color of the text.
    var color: UIColor?

    /// The typography of the text.
    var typography: POTypography?

    /// Constants that describe the preferred styles for fonts.
    var textStyle: UIFont.TextStyle?

    /// The maximum point size allowed for the font. Use this value to constrain the font to
    /// the specified size when your interface cannot accommodate text that is any larger.
    var maximumFontSize: CGFloat?

    /// Allows to alter font with the specified symbolic traits.
    var fontSymbolicTraits: UIFontDescriptor.SymbolicTraits = []

    /// The text tab objects that represent the paragraph’s tab stops.
    var tabStops: [NSTextTab] = []

    /// The indentation of the paragraph’s lines other than the first.
    var headIndent: CGFloat = 0

    /// Contents of the future attributed string. Defaults to empty string.
    var text: Text = .plain("")

    func build() -> NSAttributedString {
        switch text {
        case .markdown(let markdown):
            let visitor = AttributedStringMarkdownVisitor(builder: self)
            let document = MarkdownParser.parse(string: markdown)
            return document.accept(visitor: visitor)
        case .plain(let string):
            return NSAttributedString(string: string, attributes: buildAttributes())
        }
    }

    func buildAttributes() -> [NSAttributedString.Key: Any] {
        guard let typography else {
            preconditionFailure("Typography must be set.")
        }
        let font = font(
            typography: typography,
            symbolicTraits: fontSymbolicTraits,
            textStyle: textStyle,
            maximumFontSize: maximumFontSize
        )
        var attributes: [NSAttributedString.Key: Any] = [:]
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        attributes[.font] = font
        attributes[.baselineOffset] = baselineOffset(font: font, lineHeightMultiple: lineHeightMultiple)
        attributes[.foregroundColor] = color
        if #available(iOS 14.0, *) {
            attributes[.tracking] = typography.tracking
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.maximumLineHeight = font.lineHeight * lineHeightMultiple
        paragraphStyle.minimumLineHeight = font.lineHeight * lineHeightMultiple
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.paragraphSpacing = typography.paragraphSpacing
        paragraphStyle.alignment = alignment
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.tabStops = tabStops
        paragraphStyle.headIndent = headIndent
        attributes[.paragraphStyle] = paragraphStyle
        return attributes
    }

    // MARK: - Private Methods

    private func baselineOffset(font: UIFont, lineHeightMultiple: CGFloat) -> CGFloat {
        let offset = (font.lineHeight * lineHeightMultiple - font.capHeight) / 2 + font.descender
        if #available(iOS 16, *) {
            return offset
        }
        // Workaround for bug in UIKit. In order to shift baseline to the top, offset should be divided
        // by two on iOS < 16.
        return offset < 0 ? offset : offset / 2
    }

    private func font(
        typography: POTypography,
        symbolicTraits: UIFontDescriptor.SymbolicTraits,
        textStyle: UIFont.TextStyle?,
        maximumFontSize: CGFloat?
    ) -> UIFont {
        var font = typography.font
        if let textStyle, typography.adjustsFontForContentSizeCategory {
            font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: typography.font)
        }
        if let maximumFontSize, font.pointSize > maximumFontSize {
            font = font.withSize(maximumFontSize)
        }
        if !symbolicTraits.isEmpty, let descriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) {
            font = UIFont(descriptor: descriptor, size: 0)
        }
        return font
    }
}

extension AttributedStringBuilder {

    func with(updates: (inout AttributedStringBuilder) -> Void) -> AttributedStringBuilder {
        var builder = self
        updates(&builder)
        return builder
    }
}
