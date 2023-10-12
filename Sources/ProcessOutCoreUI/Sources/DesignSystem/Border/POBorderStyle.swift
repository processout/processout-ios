//
//  POBorderStyle.swift
//  ProcessOutCoreUI
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

/// Style that defines border appearance. Border is always a solid line.
public struct POBorderStyle {

    /// Corner radius.
    public let radius: CGFloat

    /// Border width.
    public let width: CGFloat

    /// Border color.
    public let color: UIColor

    public init(radius: CGFloat, width: CGFloat, color: UIColor) {
        self.radius = radius
        self.width = width
        self.color = color
    }
}

extension POBorderStyle {

    /// Clear border.
    public static let clear = POBorderStyle(radius: Constants.radius, width: 0, color: .clear)

    /// Regular width border.
    static func regular(color: UIColor) -> POBorderStyle {
        .init(radius: Constants.radius, width: Constants.width, color: color)
    }

    // MARK: - Private Nested Types

    private enum Constants {
        static let width: CGFloat = 1
        static let radius: CGFloat = 8
    }
}
