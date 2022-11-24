//
//  POTextStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.11.2022.
//

import UIKit

public struct POTextStyle {

    /// Text foreground color.
    public let color: UIColor

    /// Text typography.
    public let typography: POTypography

    public init(color: UIColor, typography: POTypography) {
        self.color = color
        self.typography = typography
    }
}
