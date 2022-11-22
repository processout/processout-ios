//
//  AttributedStringBuilder.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

final class AttributedStringBuilder {

    init() {
        dynamicTypeEnabled = true
        attributedString = NSMutableAttributedString()
    }

    func alignment(_ alignment: NSTextAlignment) -> AttributedStringBuilder {
        paragraphStyle.alignment = alignment
        return self
    }

    func lineBreakMode(_ mode: NSLineBreakMode) -> AttributedStringBuilder {
        paragraphStyle.lineBreakMode = mode
        return self
    }

    func textColor(_ color: ColorAsset) -> AttributedStringBuilder {
        attributes[.foregroundColor] = color.color
        return self
    }

    func typography(_ typography: POTypography) -> AttributedStringBuilder {
        self.typography = typography
        return self
    }

    /// The maximum point size allowed for the font. Use this value to constrain the font to the specified size
    /// when your interface cannot accommodate text that is any larger.
    func maximumFontSize(_ maximumSize: CGFloat?) -> AttributedStringBuilder {
        self.maximumFontSize = maximumSize
        return self
    }

    func string(_ string: String) -> AttributedStringBuilder {
        guard let typography else {
            assertionFailure("Typography must be set.")
            return self
        }
        let scaledFont = scaledFont(
            typography: typography, dynamicTypeEnabled: dynamicTypeEnabled, maximumFontSize: maximumFontSize
        )
        let lineHeightMultiple = typography.lineHeight / typography.font.lineHeight
        let scaledLineHeight = scaledFont.lineHeight * lineHeightMultiple
        configureParagraphStyle(lineHeightMultiple: lineHeightMultiple, lineHeight: scaledLineHeight)
        attributes[.font] = scaledFont
        attributes[.baselineOffset] = baselineOffset(font: scaledFont, expectedLineHeight: scaledLineHeight)
        if #available(iOS 14.0, *) {
            attributes[.tracking] = typography.tracking
        }
        attributedString.append(NSAttributedString(string: string, attributes: attributes))
        return self
    }

    func build() -> NSAttributedString {
        attributedString.copy() as! NSAttributedString // swiftlint:disable:this force_cast
    }

    // MARK: - Private Properties

    private let attributedString: NSMutableAttributedString

    private lazy var paragraphStyle: NSMutableParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineBreakMode = .byTruncatingTail
        style.alignment = .natural
        return style
    }()

    private lazy var attributes: [NSAttributedString.Key: Any] = [
        .paragraphStyle: paragraphStyle
    ]

    private var dynamicTypeEnabled: Bool
    private var maximumFontSize: CGFloat?
    private var typography: POTypography?

    // MARK: - Private Methods

    private func baselineOffset(font: UIFont, expectedLineHeight: CGFloat) -> CGFloat {
        // Workaround for bug in UIKit. In order to shift baseline to the top for the text with
        // the same baseline offset value, offset should be divided by two.
        let offset = (expectedLineHeight - font.capHeight) / 2 + font.descender
        return offset < 0 ? offset : offset / 2
    }

    private func scaledFont(typography: POTypography, dynamicTypeEnabled: Bool, maximumFontSize: CGFloat?) -> UIFont {
        guard dynamicTypeEnabled, let textStyle = typography.textStyle else {
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
