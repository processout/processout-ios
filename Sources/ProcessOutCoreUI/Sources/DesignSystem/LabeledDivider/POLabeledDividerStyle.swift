//
//  POLabeledDividerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

public struct POLabeledDividerStyle {

    /// Divider color.
    public let color: Color

    /// Label style.
    public let title: POTextStyle

    /// Creates instance.
    public init(color: Color, title: POTextStyle) {
        self.color = color
        self.title = title
    }
}

extension POLabeledDividerStyle {

    /// Default style.
    public static let `default` = POLabeledDividerStyle(
        color: Color(poResource: .Text.muted),
        title: POTextStyle(color: Color(poResource: .Text.muted), typography: .Fixed.labelHeading)
    )
}
