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
@available(iOS 14, *)
public struct PODynamicCheckoutStyle {

    /// Payment item style.
    public var payment = PODynamicCheckoutPaymentStyle()

    /// Separator color.
    public var separatorColor = Color(poResource: .Border.subtle)

    /// Background color.
    public var backgroundColor = Color(poResource: .Surface.level1)

    /// Actions container style.
    public var actionsContainer = POActionsContainerStyle.default
}
