//
//  POBorderStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

/// Style that defines border appearance. Border is always a solid line.
@MainActor
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

    /// Clear border of specified radius.
    public static func clear(radius: CGFloat) -> POBorderStyle {
        .init(radius: radius, width: 0, color: .clear)
    }

    /// Regular width border.
    static func regular(radius: CGFloat, color: UIColor) -> POBorderStyle {
        .init(radius: radius, width: 1, color: color)
    }
}
