//
//  PassKitPaymentRequestUpdate.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 18.12.2023.
//

import PassKit

struct PassKitPaymentRequestUpdate {

    init(request: PKPaymentRequest) {
        self.paymentSummaryItems = request.paymentSummaryItems
        self.shippingMethods = request.shippingMethods ?? []
    }

    /// Array of PKPaymentSummaryItem objects which should be presented to the user.
    var paymentSummaryItems: [PKPaymentSummaryItem]

    /// Shipping methods supported by the merchant.
    var shippingMethods: [PKShippingMethod]

    mutating func update(with update: PKPaymentRequestUpdate) {
        if #available(iOS 15.0, *) {
            shippingMethods = update.shippingMethods
        }
        paymentSummaryItems = update.paymentSummaryItems
    }
}
