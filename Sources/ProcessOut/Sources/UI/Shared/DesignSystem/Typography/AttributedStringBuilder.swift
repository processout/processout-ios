//
//  AttributedStringBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

final class AttributedStringBuilder {

    init() {
        string = ""
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

    func typography(_ typography: POTypography) -> AttributedStringBuilder {
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        configureParagraphStyle(lineHeightMultiple: lineHeightMultiple, lineHeight: typography.lineHeight)
        attributes[.font] = scaledFont
        attributes[.baselineOffset] = baselineOffset(font: typography.font, expectedLineHeight: typography.lineHeight)
        if #available(iOS 14.0, *) {
            attributes[.tracking] = typography.tracking
        }
        return self
    }

    /// - Parameters:
    ///   - maximumSize: The maximum point size allowed for the font. Use this value to constrain
    ///   the font to the specified size when your interface cannot accommodate text that is any larger.
    func typography(
        _ typography: POTypography, style: UIFont.TextStyle, maximumSize: CGFloat? = nil
    ) -> AttributedStringBuilder {
        let scaledFont = scaledFont(
            typography: typography, textStyle: style, maximumFontSize: maximumSize
        )
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        let scaledLineHeight = scaledFont.lineHeight * lineHeightMultiple
        configureParagraphStyle(lineHeightMultiple: lineHeightMultiple, lineHeight: scaledLineHeight)
        attributes[.font] = scaledFont
        attributes[.baselineOffset] = baselineOffset(font: scaledFont, expectedLineHeight: scaledLineHeight)
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

    func with(link: String) -> AttributedStringBuilder {
        attributes[.link] = link
        return self
    }

    func string(_ string: String) -> AttributedStringBuilder {
        self.string = string
        return self
    }

    func build() -> NSAttributedString {
        NSAttributedString(string: string, attributes: attributes)
    }

    /// - NOTE: Returned value should be used only for inspection.
    var currentAttributes: [NSAttributedString.Key: Any] {
        attributes
    }

    // MARK: - Private Properties

    private lazy var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        style.alignment = .natural
        return style
    }()

    private lazy var attributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: paragraphStyle
    ]

    private var string: String

    // MARK: - Private Methods

    private func baselineOffset(font: UIFont, expectedLineHeight: CGFloat) -> CGFloat {
        let offset = (expectedLineHeight - font.capHeight) / 2 + font.descender
        if #available(iOS 16, *) {
            return offset
        }
        // Workaround for bug in UIKit. In order to shift baseline to the top, offset should be divided
        // by two on iOS < 16.
        return offset < 0 ? offset : offset / 2
    }

    private func scaledFont(
        typography: POTypography, textStyle: UIFont.TextStyle, maximumFontSize: CGFloat?
    ) -> UIFont {
        guard typography.adjustsFontForContentSizeCategory else {
            return typography.font
        }
        let fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        let scaledFont = fontMetrics.scaledFont(
            for: typography.font, maximumPointSize: maximumFontSize ?? .greatestFiniteMagnitude
        )
        return scaledFont
    }

    private func configureParagraphStyle(lineHeightMultiple: CGFloat, lineHeight: CGFloat) {
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        paragraphStyle.maximumLineHeight = lineHeight
        paragraphStyle.minimumLineHeight = lineHeight
    }
}
