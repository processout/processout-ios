//
//  POSpacing.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import Foundation

/// A namespace containing standard spacing constants.
@_spi(PO)
public enum POSpacing {

    /// 0pt spacing.
    public static let space0: CGFloat = 0

    /// 1pt spacing.
    public static let space1: CGFloat = 1

    /// 2pt spacing.
    public static let space2: CGFloat = 2

    /// 4pt spacing.
    public static let space4: CGFloat = 4

    /// 6pt spacing.
    public static let space6: CGFloat = 6

    /// 8pt spacing.
    public static let space8: CGFloat = 8

    /// 12pt spacing.
    public static let space12: CGFloat = 12

    /// 16pt spacing.
    public static let space16: CGFloat = 16

    /// 20pt spacing.
    public static let space20: CGFloat = 20

    // MARK: -

    /// Extra extra small spacing.
    public static let extraExtraSmall: CGFloat = 2

    /// Extra small spacing.
    public static let extraSmall: CGFloat = 4

    /// Small spacing. Can be used as a spacing between adjacent
    /// items in the same section.
    public static let small: CGFloat = 8

    /// Medium spacing. To add in between different sections.
    public static let medium: CGFloat = 16

    /// Large spacing.
    public static let large: CGFloat = 20

    /// Extra large spacing.
    public static let extraLarge: CGFloat = 30

    /// Extra extra large spacing.
    public static let extraExtraLarge: CGFloat = 60
}
