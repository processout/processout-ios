//
//  POShadowStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.11.2022.
//

import UIKit

/// Style that defines shadow appearance.
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

    static let `default` = POShadowStyle(
        color: Asset.Colors.Text.primary.color.withAlphaComponent(0.1),
        offset: CGSize(width: 0, height: 8),
        radius: 24
    )

    /// Value represents no shadow.
    public static let clear = Self(color: .clear, offset: .zero, radius: 0)
}
