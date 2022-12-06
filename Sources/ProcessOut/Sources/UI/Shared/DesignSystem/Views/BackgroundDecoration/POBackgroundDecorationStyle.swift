//
//  POBackgroundDecorationStyle.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.12.2022.
//

import UIKit

public struct POBackgroundDecorationStyle {

    /// Primary color.
    public let normal: POBackgroundDecorationStateStyle

    /// Secondary color.
    public let success: POBackgroundDecorationStateStyle

    public init(normal: POBackgroundDecorationStateStyle, success: POBackgroundDecorationStateStyle) {
        self.normal = normal
        self.success = success
    }
}

extension POBackgroundDecorationStyle {

    public static let `default` = Self(
        normal: .init(
            primaryColor: Asset.Colors.Background.Grey.dark.color,
            secondaryColor: Asset.Colors.Background.Grey.light.color
        ),
        success: .init(
            primaryColor: Asset.Colors.Background.Success.dark.color,
            secondaryColor: Asset.Colors.Background.Success.light.color
        )
    )
}
