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
