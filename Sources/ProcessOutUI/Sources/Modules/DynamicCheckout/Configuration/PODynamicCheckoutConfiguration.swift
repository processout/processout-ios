//
//  PODynamicCheckoutConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import PassKit

/// Dynamic checkout configuration.
public struct PODynamicCheckoutConfiguration {

    public struct Success {

        /// Custom success message to display user when payment completes.
        public var message: String?

        /// Boolean value that indicates whether capture success screen should be skipped.
        /// Default value is `false`.
        public var skipScreen = false

        /// Defines for how long implementation delays calling completion in case of success.
        public var duration: TimeInterval = 3.0

        /// Creates configuration instance.
        public init() { }
    }

    /// Invoice ID to use to initiate a payment.
    public var invoiceId: String

    /// Card collection configuration.
    public var card = PODynamicCheckoutCardConfiguration()

    /// Alternative payment method configuration.
    public var alternativePayment = PODynamicCheckoutAlternativePaymentConfiguration()

    /// PassKit payment button type.
    public var passKitPaymentButtonType = PKPaymentButtonType.plain

    /// Primary action text, such as "Submit".
    public var primaryActionTitle: String?

    /// Cancel action. To remove action use empty string.
    public var cancelActionTitle: String?

    /// Determines whether to enable skipping payment list step when there is only
    /// one non-instant payment method. Default value: `true`.
    public var allowsSkippingPaymentList = true

    /// Success stage configuration.
    public var success: Success = .init()

    /// Creates configuration instance.
    public init(invoiceId: String) {
        self.invoiceId = invoiceId
    }
}
