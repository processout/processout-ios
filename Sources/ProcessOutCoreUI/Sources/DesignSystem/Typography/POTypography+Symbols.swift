//
//  POTypography+Symbols.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.10.2024.
//

import UIKit

@_spi(PO)
extension POTypography {

    /// Use for titles.
    public static let title = POTypography(font: UIFont(.WorkSans.medium, size: 20), lineHeight: 24)

    /// Subheading typography.
    public static let subheading = POTypography(font: UIFont(.WorkSans.medium, size: 18), lineHeight: 24)

    /// Primary body text for readability and consistency.
    public static let body1 = POTypography(font: UIFont(.WorkSans.medium, size: 16), lineHeight: 24)

    /// Secondary body text for supporting content.
    public static let body2 = POTypography(font: UIFont(.WorkSans.regular, size: 14), lineHeight: 18)

    /// Text used on buttons or interactive elements.
    public static let button = POTypography(font: UIFont(.WorkSans.medium, size: 14), lineHeight: 18)

    /// Large text for prominent labels or headings.
    public static let label1 = POTypography(font: UIFont(.WorkSans.medium, size: 14), lineHeight: 18)

    /// Smaller text for secondary labels or headings.
    public static let label2 = POTypography(font: UIFont(.WorkSans.regular, size: 14), lineHeight: 18)

    /// Registers all custom fonts.
    public static func registerFonts() {
        FontResource.register()
    }
}
