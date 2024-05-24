//
//  POTypography.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

/// Holds typesetting information that could be applied to displayed text.
public struct POTypography {

    /// Font associated with given typography.
    public let font: UIFont

    /// Line height. If not set explicitly equals to font's line height.
    public let lineHeight: CGFloat

    /// Tracking value.
    public let tracking: CGFloat?

    /// This property contains the space (measured in points) added at the end of the paragraph to separate
    /// it from the following paragraph. This value must be nonnegative. Default value is `0`.
    public let paragraphSpacing: CGFloat

    /// A Boolean that indicates whether the font should be updated when the device’s content size category changes.
    /// Default value is `true`.
    public let adjustsFontForContentSizeCategory: Bool

    /// Creates typography with provided information.
    public init(
        font: UIFont,
        lineHeight: CGFloat? = nil,
        tracking: CGFloat? = nil,
        paragraphSpacing: CGFloat = 0,
        adjustsFontForContentSizeCategory: Bool = true
    ) {
        self.font = font
        if let lineHeight {
            assert(lineHeight >= font.lineHeight, "Line height less than font's will cause clipping")
            self.lineHeight = max(lineHeight, font.lineHeight)
        } else {
            self.lineHeight = font.lineHeight
        }
        self.tracking = tracking
        self.paragraphSpacing = paragraphSpacing
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
    }
}

extension POTypography {

    enum Fixed {

        /// Use for captions, status labels and tags.
        static let caption = POTypography(font: FontFamily.WorkSans.regular.font(size: 12), lineHeight: 16)

        /// Use for buttons.
        static let button = POTypography(font: FontFamily.WorkSans.medium.font(size: 14), lineHeight: 18)

        /// Use for body copy on larger screens, or smaller blocks of text.
        static let body = POTypography(
            font: FontFamily.WorkSans.regular.font(size: 16), lineHeight: 24, paragraphSpacing: 8
        )

        /// Use for form components, error text and key value data.
        static let label = POTypography(font: FontFamily.WorkSans.regular.font(size: 14), lineHeight: 18)

        /// Use for form components, error text and key value data.
        static let labelHeading = POTypography(font: FontFamily.WorkSans.medium.font(size: 14), lineHeight: 18)
    }

    enum Medium {

        /// Use for page titles.
        static let title = POTypography(font: FontFamily.WorkSans.medium.font(size: 20), lineHeight: 28)
    }
}
