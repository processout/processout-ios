//
//  POTextStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import SwiftUI

/// Text style.
public struct POTextStyle: Sendable {

    /// Text foreground color.
    public let color: Color

    /// Text typography.
    public let typography: POTypography

    public init(color: Color, typography: POTypography) {
        self.color = color
        self.typography = typography
    }
}

extension POTextStyle {

    /// Auxiliary method that returns same text style with given scale applied to its typography.
    func scaledBy(_ scale: CGFloat) -> POTextStyle {
        .init(color: color, typography: typography.scaledBy(scale))
    }
}
