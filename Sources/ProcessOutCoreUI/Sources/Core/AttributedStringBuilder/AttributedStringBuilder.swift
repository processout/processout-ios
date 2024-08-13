//
//  AttributedStringBuilder.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import SwiftUI

@available(iOS 14.0, *)
struct AttributedStringBuilder {

    /// The typography of the text.
    var typography: POTypography

    /// Allows to alter font with the specified symbolic traits.
    var fontSymbolicTraits: UIFontDescriptor.SymbolicTraits = []

    /// Font feature settings.
    var fontFeatures = POFontFeaturesSettings()

    /// Allows to override current trait collection's size category with custom value.
    var sizeCategory: UIContentSizeCategory

    /// The color of the text.
    var color: Color

    /// The text alignment of the paragraph.
    var alignment: NSTextAlignment = .natural

    /// The mode for breaking lines in the paragraph.
    var lineBreakMode: NSLineBreakMode = .byTruncatingTail

    /// The text tab objects that represent the paragraph’s tab stops.
    var tabStops: [NSTextTab] = []

    /// The indentation of the paragraph’s lines other than the first.
    var headIndent: CGFloat = 0

    // MARK: -

    func build(markdown: String) -> NSAttributedString {
        let visitor = AttributedStringMarkdownVisitor(builder: self)
        let document = MarkdownParser.parse(string: markdown)
        return document.accept(visitor: visitor)
    }

    func build(string: String) -> NSAttributedString {
        let attributes = buildAttributes()
        return NSAttributedString(string: string, attributes: attributes)
    }

    func buildAttributes() -> [NSAttributedString.Key: Any] {
        let font = font(typography: typography)
        var attributes: [NSAttributedString.Key: Any] = [:]
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        attributes[.font] = font
        attributes[.baselineOffset] = Self.baselineOffset(font: font, lineHeightMultiple: lineHeightMultiple)
        attributes[.foregroundColor] = UIColor(color)
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

    private static func baselineOffset(font: UIFont, lineHeightMultiple: CGFloat) -> CGFloat {
        let offset = (font.lineHeight * lineHeightMultiple - font.capHeight) / 2 + font.descender
        if #available(iOS 16, *) {
            return offset
        }
        // Workaround for bug in UIKit. In order to shift baseline to the top, offset should be divided
        // by two on iOS < 16.
        return offset < 0 ? offset : offset / 2
    }

    private func font(typography: POTypography) -> UIFont {
        var font = typography.font
        if let textStyle = typography.textStyle {
            let traits = UITraitCollection(
                traitsFrom: [.current, .init(preferredContentSizeCategory: sizeCategory)]
            )
            font = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: typography.font, compatibleWith: traits)
        }
        if !fontSymbolicTraits.isEmpty, let descriptor = font.fontDescriptor.withSymbolicTraits(fontSymbolicTraits) {
            font = UIFont(descriptor: descriptor, size: 0)
        }
        return font.addingFeatures(fontFeatures)
    }
}

@available(iOS 14.0, *)
extension AttributedStringBuilder {

    func with(updates: (inout AttributedStringBuilder) -> Void) -> AttributedStringBuilder {
        var builder = self
        updates(&builder)
        return builder
    }
}
