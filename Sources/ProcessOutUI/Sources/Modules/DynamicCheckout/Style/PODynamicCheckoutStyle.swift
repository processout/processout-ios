//
//  PODynamicCheckoutStyle.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.02.2024.
//

import SwiftUI
@_spi(PO) import ProcessOutCoreUI

/// Defines style for dynamic checkout view.
///
/// For more information about styling specific components, see
/// [the dedicated documentation.](https://swiftpackageindex.com/processout/processout-ios/documentation/processoutcoreui)
public struct PODynamicCheckoutStyle {

    /// Background color.
    public let backgroundColor: Color

    public init(backgroundColor: Color) {
        self.backgroundColor = backgroundColor
    }
}

extension PODynamicCheckoutStyle {

    /// Default card tokenization style.
    public static var `default`: PODynamicCheckoutStyle {
        PODynamicCheckoutStyle(backgroundColor: Color(poResource: .Surface.level1))
    }
}
