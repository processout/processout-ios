//
//  PODynamicCheckoutCardConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import ProcessOut

public struct PODynamicCheckoutCardConfiguration {

    /// Card billing address collection configuration.
    public var billingAddress = PODynamicCheckoutCardBillingAddressConfiguration()

    /// Metadata related to the card.
    public var metadata: [String: String]?
}

/// Billing address collection configuration.
public struct PODynamicCheckoutCardBillingAddressConfiguration {

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
