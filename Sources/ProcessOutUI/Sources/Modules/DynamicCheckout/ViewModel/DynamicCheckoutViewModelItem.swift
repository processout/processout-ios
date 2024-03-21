//
//  DynamicCheckoutViewModelItem.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import SwiftUI

enum DynamicCheckoutViewModelItem {

    struct ExpressPaymentItem: Identifiable {

        /// Item id.
        let id: String

        /// Item title.
        let title: String?

        /// Payment icon image
        let iconImage: Image?

        /// Brand color.
        let brandColor: Color

        /// Boolean value indicating whether button should display loading indicator.
        let isLoading: Bool

        /// Action handler.
        let action: () -> Void
    }

    struct PaymentItem: Identifiable {

        /// Item identifier.
        let id: String

        /// Payment icon image
        let iconImage: Image?

        /// Item title.
        let title: String

        /// Defines whether item is currently selected.
        var isSelected: Binding<Bool>

        /// Payment details.
        let additionalInformation: String?
    }

    /// Progress item.
    case progress

    /// Express payment item.
    case expressPayment(ExpressPaymentItem)

    /// Payment item.
    case payment(PaymentItem)

    /// Card item.
    case card

    /// Alternative payment.
    case nativeAlternativePayment(gatewayId: String)
}
