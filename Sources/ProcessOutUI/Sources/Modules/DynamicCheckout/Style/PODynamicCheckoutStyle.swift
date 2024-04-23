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

    public struct PaymentsSection {

        /// Section title style if any.
        public var title = POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title)

        /// Section border style.
        public var border = POBorderStyle.regular(color: Color(poResource: .Text.muted))
    }

    public struct PaymentHeader {

        /// Title style.
        public var title = POTextStyle(color: Color(poResource: .Text.primary), typography: .Medium.title)

        /// Information text style.
        public var informationText = POTextStyle(color: Color(poResource: .Text.primary), typography: .Fixed.body)
    }

    /// Payments section style.
    public var paymentsSection = PaymentsSection()

    /// Style to apply to divider sepparating different sections.
    public var sectionsDivider = POLabeledDividerStyle()

    /// Payment item's header style.
    public var paymentHeader = PaymentHeader()

    /// Background color.
    public var backgroundColor = Color(poResource: .Surface.level1)

    /// Actions container style.
    public var actionsContainer = POActionsContainerStyle.default

    /// Creates style instance.
    public init() { }
}
