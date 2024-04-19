//
//  POLabeledDividerStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 19.04.2024.
//

import SwiftUI

public struct POLabeledDividerStyle {

    /// Divider color.
    public var color = Color(poResource: .Border.subtle)

    /// Label style.
    public var title = POTextStyle(color: Color(poResource: .Border.subtle), typography: .Fixed.labelHeading)
}
