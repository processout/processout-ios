//
//  POTypography.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.11.2022.
//

import UIKit

public struct POTypography {

    /// Font assosiated with given typography.
    public let font: UIFont

    /// Line height.
    public let lineHeight: CGFloat

    /// Tracking value.
    public let tracking: CGFloat?

    /// A Boolean that indicates whether the font should be updated when the device’s content size category changes.
    public let adjustsFontForContentSizeCategory: Bool

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

    // MARK: - Title

    /// Title/Title2
    static let title = POTypography(
        font: .systemFont(ofSize: 22, weight: .semibold), lineHeight: 28, tracking: 0.36
    )

    // MARK: - Headline

    static let headline = POTypography(
        font: .systemFont(ofSize: 17, weight: .medium), lineHeight: 22, tracking: -0.44
    )

    // MARK: - Body

    static let bodyLarge = POTypography(
        font: .systemFont(ofSize: 17, weight: .regular), lineHeight: 22, tracking: -0.41
    )

    /// Body/Default +
    static let bodyDefault2 = POTypography(
        font: .systemFont(ofSize: 15, weight: .medium), lineHeight: 20, tracking: -0.24
    )

    /// Body/Default
    static let bodyDefault1 = POTypography(
        font: .systemFont(ofSize: 15, weight: .regular), lineHeight: 20, tracking: -0.24
    )

    /// Body/Small +
    static let bodySmall2 = POTypography(
        font: .systemFont(ofSize: 13, weight: .medium), lineHeight: 18, tracking: -0.08
    )

    /// Body/Small
    static let bodySmall1 = POTypography(
        font: .systemFont(ofSize: 13, weight: .regular), lineHeight: 18, tracking: -0.08
    )

    // MARK: - Input

    static let inputLabel = POTypography(
        font: .systemFont(ofSize: 15, weight: .regular), lineHeight: 20, tracking: -0.24
    )

    static let inputString = POTypography(
        font: .systemFont(ofSize: 15, weight: .regular), lineHeight: 20, tracking: -0.24
    )

    // MARK: - Action

    /// Action/Default +
    static let actionDefault2 = POTypography(
        font: .systemFont(ofSize: 15, weight: .medium), lineHeight: 20, tracking: -0.24
    )

    /// Action/Default
    static let actionDefault1 = POTypography(
        font: .systemFont(ofSize: 15, weight: .regular), lineHeight: 20, tracking: -0.24
    )
}
