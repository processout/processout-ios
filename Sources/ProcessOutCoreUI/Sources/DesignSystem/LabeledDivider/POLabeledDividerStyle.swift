//
//  POLabeledDividerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

public struct POLabeledDividerStyle {

    /// Divider color.
    public var color = Color(poResource: .Text.muted)

    /// Label style.
    public var title = POTextStyle(color: Color(poResource: .Text.muted), typography: .Fixed.labelHeading)

    /// Creates default divider style.
    public init() { }
}
