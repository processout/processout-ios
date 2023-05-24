//
//  POTypography.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

/// Holds typesetting information that could be applied to displayed text.
public struct POTypography {

    /// Font assosiated with given typography.
    public let font: UIFont

    /// Line height. If not set explicitly equals to font's line height.
    public let lineHeight: CGFloat

    /// Tracking value.
    public let tracking: CGFloat?

    /// A Boolean that indicates whether the font should be updated when the device’s content size category changes.
    /// Default value is `true`.
    public let adjustsFontForContentSizeCategory: Bool

    /// Creates typography with provided information.
    public init(
        font: UIFont,
        lineHeight: CGFloat? = nil,
        tracking: CGFloat? = nil,
        adjustsFontForContentSizeCategory: Bool = true
    ) {
        self.font = font
        self.lineHeight = lineHeight ?? font.lineHeight
        self.tracking = tracking
        self.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
    }
}

extension POTypography {

    enum Fixed {

        /// Use for captions, status labels and tags.
        static let caption = POTypography(font: FontFamily.WorkSans.regular.font(size: 12), lineHeight: 16)

        /// Use for captions, status labels and tags.
        static let tag = POTypography(font: FontFamily.WorkSans.medium.font(size: 12), lineHeight: 16)

        /// Use for buttons.
        static let button = POTypography(font: FontFamily.WorkSans.medium.font(size: 14), lineHeight: 14)

        /// Use in tables, when information density is important.
        static let tabular = POTypography(font: FontFamily.WorkSans.regular.font(size: 14), lineHeight: 20)

        /// Use for body copy on larger screens, or smaller blocks of text.
        static let body = POTypography(font: FontFamily.WorkSans.regular.font(size: 16), lineHeight: 24)

        /// Use for form components, error text and key value data.
        static let label = POTypography(font: FontFamily.WorkSans.regular.font(size: 14), lineHeight: 18)

        /// Use for form components, error text and key value data.
        static let labelHeading = POTypography(font: FontFamily.WorkSans.medium.font(size: 14), lineHeight: 18)
    }

    enum Medium {

        /// Use for section headings.
        static let subtitle = POTypography(font: FontFamily.WorkSans.medium.font(size: 18), lineHeight: 24)

        /// Use for page titles.
        static let title = POTypography(font: FontFamily.WorkSans.medium.font(size: 20), lineHeight: 28)

        /// Use for page headlines.
        static let headline = POTypography(font: FontFamily.WorkSans.medium.font(size: 24), lineHeight: 32)

        /// Use for display text
        static let display = POTypography(font: FontFamily.WorkSans.medium.font(size: 36), lineHeight: 44)
    }

    enum Large {

        /// Use for section headings.
        static let subtitle = POTypography(font: FontFamily.WorkSans.medium.font(size: 20), lineHeight: 28)

        /// Use for page titles.
        static let title = POTypography(font: FontFamily.WorkSans.medium.font(size: 24), lineHeight: 32)

        /// Use for page headlines.
        static let headline = POTypography(font: FontFamily.WorkSans.medium.font(size: 32), lineHeight: 40)

        /// Use for display text
        static let display = POTypography(font: FontFamily.WorkSans.medium.font(size: 48), lineHeight: 48)
    }
}
