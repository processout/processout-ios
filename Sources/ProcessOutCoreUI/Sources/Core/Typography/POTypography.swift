//
//  POTypography.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

/// Holds typesetting information that could be applied to displayed text.
public struct POTypography: Sendable {

    /// Font associated with given typography.
    public let font: UIFont

    /// A dynamic text style to use for font. Pass `nil` to opt out from Dynamic Type and use fixed font size.
    /// Default value is `.body`.
    public let textStyle: UIFont.TextStyle?

    /// Line height. If not set explicitly equals to font's line height.
    public let lineHeight: CGFloat

    /// This property contains the space (measured in points) added at the end of the paragraph to separate
    /// it from the following paragraph. This value must be nonnegative. Default value is `0`.
    public let paragraphSpacing: CGFloat

    /// Sets the spacing, or kerning, between characters.
    @available(iOS 16, *)
    public var kerning: CGFloat {
        _kerning
    }

    /// Creates typography with provided information.
    public init(
        font: UIFont,
        textStyle: UIFont.TextStyle? = .body,
        lineHeight: CGFloat? = nil,
        paragraphSpacing: CGFloat = 0
    ) {
        self.font = font
        self.textStyle = textStyle
        self.lineHeight = Self.corrected(lineHeight: lineHeight, font: font)
        self.paragraphSpacing = paragraphSpacing
        _kerning = 0
    }

    /// Creates typography with provided information.
    @available(iOS 16, *)
    public init(
        font: UIFont,
        textStyle: UIFont.TextStyle? = .body,
        lineHeight: CGFloat? = nil,
        paragraphSpacing: CGFloat = 0,
        kerning: CGFloat
    ) {
        self.font = font
        self.textStyle = textStyle
        self.lineHeight = Self.corrected(lineHeight: lineHeight, font: font)
        self.paragraphSpacing = paragraphSpacing
        self._kerning = kerning
    }

    // MARK: - Private Properties

    private let _kerning: CGFloat

    // MARK: - Private Methods

    private static func corrected(lineHeight: CGFloat?, font: UIFont) -> CGFloat {
        if let lineHeight {
            assert(lineHeight >= font.lineHeight, "Line height less than font's will cause clipping")
            return max(lineHeight, font.lineHeight)
        }
        return font.lineHeight
    }
}

extension POTypography {

    /// Returns a typography object that is the same as the typography, but has
    /// size, line height and paragraph spacing scaled.
    func scaledBy(_ scale: CGFloat) -> POTypography {
        .init(
            font: font.withSize(font.pointSize * scale),
            textStyle: textStyle,
            lineHeight: lineHeight * scale,
            paragraphSpacing: paragraphSpacing * scale
        )
    }
}
