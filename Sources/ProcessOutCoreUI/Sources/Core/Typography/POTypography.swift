//
//  POTypography.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

/// Holds typesetting information that could be applied to displayed text.
public struct POTypography {

    /// Font assosiated with given typography.
    public let font: UIFont

    /// A dynamic text style to use for font. Pass `nil` to opt out from Dynamic Type and use fixed font size.
    /// Default value is `.body`.
    public let textStyle: UIFont.TextStyle?

    /// Line height. If not set explicitly equals to font's line height.
    public let lineHeight: CGFloat

    /// This property contains the space (measured in points) added at the end of the paragraph to separate
    /// it from the following paragraph. This value must be nonnegative. Default value is `0`.
    public let paragraphSpacing: CGFloat

    /// Creates typography with provided information.
    public init(
        font: UIFont, textStyle: UIFont.TextStyle? = .body, lineHeight: CGFloat? = nil, paragraphSpacing: CGFloat = 0
    ) {
        self.font = font
        self.textStyle = textStyle
        if let lineHeight {
            assert(lineHeight >= font.lineHeight, "Line height less than font's will cause clipping")
            self.lineHeight = max(lineHeight, font.lineHeight)
        } else {
            self.lineHeight = font.lineHeight
        }
        self.paragraphSpacing = paragraphSpacing
    }
}

@_spi(PO)
extension POTypography {

    /// Use for titles.
    public static let title = POTypography(font: UIFont(.WorkSans.medium, size: 20), lineHeight: 24)

    /// Primary body text for readability and consistency.
    public static let body1 = POTypography(font: UIFont(.WorkSans.medium, size: 16), lineHeight: 20)

    /// Secondary body text for supporting content.
    public static let body2 = POTypography(font: UIFont(.WorkSans.regular, size: 16), lineHeight: 20)

    /// Text used on buttons or interactive elements.
    public static let button = POTypography(font: UIFont(.WorkSans.medium, size: 16), lineHeight: 24)

    /// Large text for prominent labels or headings.
    public static let label1 = POTypography(font: UIFont(.WorkSans.medium, size: 16), lineHeight: 24)

    /// Smaller text for secondary labels or headings.
    public static let label2 = POTypography(font: UIFont(.WorkSans.regular, size: 16), lineHeight: 24)

    /// Registers all custom fonts.
    public static func registerFonts() {
        FontResource.register()
    }
}
