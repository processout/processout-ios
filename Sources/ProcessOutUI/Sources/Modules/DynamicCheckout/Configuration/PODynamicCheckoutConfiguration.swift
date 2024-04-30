//
//  PODynamicCheckoutConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit

/// Dynamic checkout configuration.
public struct PODynamicCheckoutConfiguration {

    public init(invoiceId: String) {
        self.invoiceId = invoiceId
    }

    /// Invoice ID to use to initiate a payment.
    public var invoiceId: String

    /// Card collection configuration.
    public var card = PODynamicCheckoutCardConfiguration()

    /// Alternative payment method configuration.
    public var alternativePayment = PODynamicCheckoutAlternativePaymentConfiguration()

    /// PassKit payment button type.
    /// - TODO: respect this configuration in UI.
    public var passKitPaymentButtonType = PKPaymentButtonType.plain

    /// Cancel action. To remove action use empty string.
    public var cancelActionTitle: String?

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `false`.
    public var allowsSkippingPaymentList = false
}
