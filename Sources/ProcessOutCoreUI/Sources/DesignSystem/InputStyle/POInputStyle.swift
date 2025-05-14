//
//  POInputStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 24.05.2023.
//

import SwiftUI

/// Defines input control style in both normal and error states.
@MainActor
@preconcurrency
public struct POInputStyle {

    /// Style for normal state.
    public let normal: POInputStateStyle

    /// Style for error state.
    public let error: POInputStateStyle

    /// Style for focused state.
    public let focused: POInputStateStyle

    /// Style for focused state while in error.
    public let errorFocused: POInputStateStyle

    /// Creates style instance.
    public init(
        normal: POInputStateStyle,
        error: POInputStateStyle,
        focused: POInputStateStyle? = nil,
        errorFocused: POInputStateStyle? = nil
    ) {
        self.normal = normal
        self.error = error
        self.focused = focused ?? normal
        self.errorFocused = errorFocused ?? self.focused
    }
}
