//
//  POBorderStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import SwiftUI

/// Style that defines border appearance. Border is always a solid line.
public struct POBorderStyle {

    /// Corner radius.
    public let radius: CGFloat

    /// Border width.
    public let width: CGFloat

    /// Border color.
    public let color: Color

    public init(radius: CGFloat, width: CGFloat, color: Color) {
        self.radius = radius
        self.width = width
        self.color = color
    }
}

extension POBorderStyle {

    /// Clear border with default corner radius.
    public static let clear = POBorderStyle(radius: Constants.radius, width: 0, color: .clear)

    /// Border style with default width and corner radius.
    public static func regular(color: Color) -> POBorderStyle {
        .init(radius: Constants.radius, width: Constants.width, color: color)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let width: CGFloat = 1
        static let radius: CGFloat = 8
    }
}
