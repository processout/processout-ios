//
//  PODynamicCheckoutCardConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import ProcessOut

/// Card specific dynamic checkout configuration.
@_spi(PO)
public struct PODynamicCheckoutCardConfiguration: Sendable {

    /// Billing address collection configuration.
    public struct BillingAddress: Sendable {

        /// Default address information.
        public let defaultAddress: POContact?

        /// Whether the values included in ``POBillingAddressConfiguration/defaultAddress`` should be attached to the
        /// card, this includes fields that aren't displayed in the form.
        ///
        /// If `false` (the default), those values will only be used to pre-fill the corresponding fields in the form.
        public let attachDefaultsToPaymentMethod: Bool

        /// Creates billing address configuration.
        public init(defaultAddress: POContact? = nil, attachDefaultsToPaymentMethod: Bool = false) {
            self.defaultAddress = defaultAddress
            self.attachDefaultsToPaymentMethod = attachDefaultsToPaymentMethod
        }
    }

    /// Card billing address collection configuration.
    public let billingAddress: BillingAddress

    /// Metadata related to the card.
    public let metadata: [String: String]?

    /// Creates configuration instance.
    public init(billingAddress: BillingAddress = BillingAddress(), metadata: [String: String]? = nil) {
        self.billingAddress = billingAddress
        self.metadata = metadata
    }
}
