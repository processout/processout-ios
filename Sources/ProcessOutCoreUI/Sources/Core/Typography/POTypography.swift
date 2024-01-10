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

extension POTypography {

    @_spi(PO) public enum Fixed {

        /// Use for buttons.
        static let button = POTypography(font: UIFont(.WorkSans.medium, size: 14), lineHeight: 18)

        /// Use for form components, error text and key value data.
        public static let label = POTypography(font: UIFont(.WorkSans.regular, size: 14), lineHeight: 18)

        /// Use for body copy on larger screens, or smaller blocks of text.
        public static let body = POTypography(
            font: UIFont(.WorkSans.regular, size: 16), lineHeight: 24, paragraphSpacing: POSpacing.small
        )

        /// Use for form components, error text and key value data.
        public static let labelHeading = POTypography(
            font: UIFont(.WorkSans.medium, size: 14), textStyle: .subheadline, lineHeight: 18
        )
    }

    @_spi(PO) public enum Medium {

        /// Use for page titles.
        public static let title = POTypography(
            font: UIFont(.WorkSans.medium, size: 20), textStyle: .title1, lineHeight: 28
        )
    }

    /// Registers all custom fonts.
    @_spi(PO) public static func registerFonts() {
        FontResource.register()
    }
}
