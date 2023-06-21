//
//  AttributedStringBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

final class AttributedStringBuilder {

    init() {
        paragraphStyle = NSMutableParagraphStyle()
        attributes = [:]
        text = .plain("")
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.tabStops = []
    }

    func alignment(_ alignment: NSTextAlignment) -> AttributedStringBuilder {
        paragraphStyle.alignment = alignment
        return self
    }

    func lineBreakMode(_ mode: NSLineBreakMode) -> AttributedStringBuilder {
        paragraphStyle.lineBreakMode = mode
        return self
    }

    func textColor(_ color: UIColor) -> AttributedStringBuilder {
        attributes[.foregroundColor] = color
        return self
    }

    /// - Parameters:
    ///   - maximumSize: The maximum point size allowed for the font. Use this value to constrain
    ///   the font to the specified size when your interface cannot accommodate text that is any larger.
    func typography(
        _ typography: POTypography, style: UIFont.TextStyle? = nil, maximumSize: CGFloat? = nil
    ) -> AttributedStringBuilder {
        let scaledFont = scaledFont(
            typography: typography, textStyle: style, maximumFontSize: maximumSize
        )
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.paragraphSpacing = typography.paragraphSpacing
        attributes[.font] = scaledFont
        attributes[.baselineOffset] = baselineOffset(font: scaledFont, lineHeightMultiple: lineHeightMultiple)
        if #available(iOS 14.0, *) {
            attributes[.tracking] = typography.tracking
        }
        return self
    }

    func with(symbolicTraits: UIFontDescriptor.SymbolicTraits) -> AttributedStringBuilder {
        guard let font = attributes[.font] as? UIFont else {
            preconditionFailure("Font must be set to apply different traits")
        }
        guard let adjustedFontDescriptor = font.fontDescriptor.withSymbolicTraits(symbolicTraits) else {
            assertionFailure("Unable to apply traits \(symbolicTraits) to font")
            return self
        }
        attributes[.font] = UIFont(descriptor: adjustedFontDescriptor, size: 0)
        return self
    }

    /// Can be used to format list items of kind TAB MARKER TAB CONTENT
    func listLevel(_ level: Int) -> AttributedStringBuilder {
        let contentIndentation = CGFloat(level + 1) * Constants.indentationWidth
        paragraphStyle.tabStops = [
            NSTextTab(textAlignment: .right, location: contentIndentation - Constants.listContentSpacing),
            NSTextTab(textAlignment: .left, location: contentIndentation)
        ]
        paragraphStyle.headIndent = contentIndentation
        return self
    }

    func with(link: String) -> AttributedStringBuilder {
        attributes[.link] = link
        return self
    }

    func string(_ string: String) -> AttributedStringBuilder {
        self.text = .plain(string)
        return self
    }

    func markdown(_ markdown: String) -> AttributedStringBuilder {
        self.text = .markdown(markdown)
        return self
    }

    func build() -> NSAttributedString {
        defer {
            // According to documentation paragraph style shouldn't be mutabled after used with attributed string
            // so in case builder will be used to build more strings we are creating copy of it.
            // swiftlint:disable:next force_cast
            paragraphStyle = paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        }
        switch text {
        case .markdown(let markdown):
            let builder = copy()
            let visitor = AttributedStringMarkdownVisitor(stringBuilder: builder)
            let document = MarkdownParser().parse(string: markdown)
            return document.accept(visitor: visitor)
        case .plain(let string):
            return NSAttributedString(string: string, attributes: currentAttributes)
        }
    }

    /// - NOTE: Returned value should be used only for inspection.
    var currentAttributes: [NSAttributedString.Key: Any] {
        var attributes = self.attributes
        attributes[.paragraphStyle] = paragraphStyle.copy() as! NSParagraphStyle // swiftlint:disable:this force_cast
        return attributes
    }

    // MARK: - Prototype

    func copy() -> AttributedStringBuilder {
        AttributedStringBuilder(attributes: attributes, paragraphStyle: paragraphStyle, text: text)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let indentationWidth: CGFloat = 32
        static let listContentSpacing: CGFloat = 4
    }

    private enum Text {
        case plain(String), markdown(String)
    }

    // MARK: - Private Properties

    private var paragraphStyle: NSMutableParagraphStyle
    private var attributes: [NSAttributedString.Key: Any] // Doesn't include paragraph style
    private var text: Text

    // MARK: - Private Methods

    private init(attributes: [NSAttributedString.Key: Any], paragraphStyle: NSParagraphStyle, text: Text) {
        self.attributes = attributes
        // swiftlint:disable:next force_cast
        self.paragraphStyle = paragraphStyle.mutableCopy() as! NSMutableParagraphStyle
        self.text = text
    }

    private func baselineOffset(font: UIFont, lineHeightMultiple: CGFloat) -> CGFloat {
        let offset = (font.lineHeight * lineHeightMultiple - font.capHeight) / 2 + font.descender
        if #available(iOS 16, *) {
            return offset
        }
        // Workaround for bug in UIKit. In order to shift baseline to the top, offset should be divided
        // by two on iOS < 16.
        return offset < 0 ? offset : offset / 2
    }

    private func scaledFont(
        typography: POTypography, textStyle: UIFont.TextStyle?, maximumFontSize: CGFloat?
    ) -> UIFont {
        var scaledFont = typography.font
        if let textStyle, typography.adjustsFontForContentSizeCategory {
            scaledFont = UIFontMetrics(forTextStyle: textStyle).scaledFont(for: typography.font)
        }
        if let maximumFontSize, scaledFont.pointSize > maximumFontSize {
            scaledFont = scaledFont.withSize(maximumFontSize)
        }
        return scaledFont
    }
}
