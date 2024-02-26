//
//  POCardScannerStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for card scanner view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
@_spi(PO) public struct POCardScannerStyle {

    /// Title style.
    public let title: POTextStyle

    /// Background color.
    public let backgroundColor: Color

    public init(title: POTextStyle, backgroundColor: Color) {
        self.title = title
        self.backgroundColor = backgroundColor
    }
}

extension POCardScannerStyle {

    /// Default card tokenization style.
    public static var `default`: POCardScannerStyle {
        POCardScannerStyle(
            title: POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title),
            backgroundColor: Color(poResource: .Surface.level1)
        )
    }
}
