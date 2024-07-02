//
//  POSpacing.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 27.11.2023.
//

import Foundation

@_spi(PO) public enum POSpacing {

    /// Extra small spacing.
    public static let extraSmall: CGFloat = 4

    /// Small spacing. Can be used as a spacing between adjacent
    /// items in the same section.
    public static let small: CGFloat = 8

    /// Medium spacing. To add in between different sections.
    public static let medium: CGFloat = 16

    /// Large spacing.
    public static let large: CGFloat = 20
}
