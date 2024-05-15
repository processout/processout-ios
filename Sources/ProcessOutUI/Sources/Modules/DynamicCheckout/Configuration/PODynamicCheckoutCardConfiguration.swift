//
//  PODynamicCheckoutCardConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

import ProcessOut

public struct PODynamicCheckoutCardConfiguration {

    /// Primary action text, such as "Submit".
    public var primaryActionTitle: String?

    /// Card billing address collection configuration.
    public var billingAddress = PODynamicCheckoutCardBillingAddressConfiguration()

    /// Metada related to the card.
    public var metadata: [String: String]?
}

/// Billing address collection configuration.
public struct PODynamicCheckoutCardBillingAddressConfiguration {

    /// Default address information.
    public let defaultAddress: POContact?

    /// Whether the values included in ``POBillingAddressConfiguration/defaultAddress`` should be attached to the
    /// card, this includes fields that aren't displayed in the form.
    ///
    /// If `false` (the default), those values will only be used to prefill the corresponding fields in the form.
    public let attachDefaultsToPaymentMethod: Bool

    /// Creates billing address configuration.
    public init(defaultAddress: POContact? = nil, attachDefaultsToPaymentMethod: Bool = false) {
        self.defaultAddress = defaultAddress
        self.attachDefaultsToPaymentMethod = attachDefaultsToPaymentMethod
    }
}
