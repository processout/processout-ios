//
//  POShadowStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

/// Style that defines shadow appearance.
@MainActor
public struct POShadowStyle {

    /// The color of the shadow.
    public let color: UIColor

    /// The offset (in points) of the shadow.
    public let offset: CGSize

    /// The blur radius (in points) used to render the shadow.
    public let radius: CGFloat

    public init(color: UIColor, offset: CGSize, radius: CGFloat) {
        self.color = color
        self.offset = offset
        self.radius = radius
    }
}

extension POShadowStyle {

    /// Value represents no shadow.
    public static let clear = Self(color: .clear, offset: .zero, radius: 0)

    static let level1 = POShadowStyle(
        color: shadowColor, offset: CGSize(width: 0, height: 4), radius: 16
    )

    static let level2 = POShadowStyle(
        color: shadowColor, offset: CGSize(width: 0, height: 8), radius: 20
    )

    static let level3 = POShadowStyle(
        color: shadowColor, offset: CGSize(width: 0, height: 12), radius: 24
    )

    static let level4 = POShadowStyle(
        color: shadowColor, offset: CGSize(width: 0, height: 16), radius: 32
    )

    static let level5 = POShadowStyle(
        color: shadowColor, offset: CGSize(width: 0, height: 20), radius: 40
    )

    // MARK: - Private Properties

    private static let shadowColor = UIColor.black.withAlphaComponent(0.08)
}
