//
//  POBackgroundDecorationStateStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import UIKit

public struct POBackgroundDecorationStateStyle {

    /// Primary color.
    public let primaryColor: UIColor

    /// Secondary color.
    public let secondaryColor: UIColor

    public init(primaryColor: UIColor, secondaryColor: UIColor) {
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
    }
}
