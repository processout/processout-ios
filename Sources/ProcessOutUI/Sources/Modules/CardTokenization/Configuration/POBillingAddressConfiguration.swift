//
//  POBillingAddressConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 23.08.2023.
//

import ProcessOut

/// Billing address collection configuration.
public struct POBillingAddressConfiguration {

    public enum CollectionMode {

        /// Only collect address components that are needed for particular payment method.
        case automatic

        /// Never collect address.
        case never

        /// Collect the full billing address.
        case full
    }

    /// Billing address collection mode.
    public let mode: CollectionMode

    /// List of ISO country codes that is supported for the billing address. When nil, all countries are provided.
    public let countryCodes: Set<String>?

    /// Default address information.
    public let defaultAddress: POContact?

    /// Whether the values included in ``POBillingAddressConfiguration/defaultAddress`` should be attached to the
    /// card, this includes fields that aren't displayed in the form.
    ///
    /// If `false` (the default), those values will only be used to prefill the corresponding fields in the form.
    public let attachDefaultsToPaymentMethod: Bool

    /// Creates billing address configuration.
    public init(
        mode: CollectionMode = .automatic,
        countryCodes: Set<String>? = nil,
        defaultAddress: POContact? = nil,
        attachDefaultsToPaymentMethod: Bool = false
    ) {
        self.countryCodes = countryCodes
        self.mode = mode
        self.defaultAddress = defaultAddress
        self.attachDefaultsToPaymentMethod = attachDefaultsToPaymentMethod
    }
}
