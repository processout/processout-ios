//
//  POCheckboxToggleStateStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 29.07.2024.
//

import SwiftUI

/// Describes checkbox style in a particular state.
public struct POCheckboxToggleStateStyle: Sendable {

    public struct Checkmark: Sendable {

        /// Checkmark color.
        public let color: Color

        /// Checkmark width.
        public let width: CGFloat

        /// Background color.
        public let backgroundColor: Color

        /// Border style.
        public let border: POBorderStyle

        /// Creates checkmark style instance.
        public init(color: Color, width: CGFloat, backgroundColor: Color, border: POBorderStyle) {
            self.color = color
            self.width = width
            self.backgroundColor = backgroundColor
            self.border = border
        }
    }

    /// Checkmark style.
    public let checkmark: Checkmark

    /// Text style.
    public let value: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    /// Creates style instance.
    public init(checkmark: Checkmark, value: POTextStyle, backgroundColor: Color = .clear) {
        self.checkmark = checkmark
        self.value = value
        self.backgroundColor = backgroundColor
    }
}
