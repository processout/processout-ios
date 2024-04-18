//
//  PODynamicCheckoutCardConfiguration.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 27.02.2024.
//

public struct PODynamicCheckoutCardConfiguration {

    /// Indicates if the input for entering the cardholder name should be
    /// displayed. Defaults to `true`.
    public var isCardholderNameInputVisible = true

    /// Primary action text, such as "Submit".
    public var primaryActionTitle: String?

    /// Card billing address collection configuration.
    public var billingAddress = POBillingAddressConfiguration()

    /// Metada related to the card.
    public var metadata: [String: String]?
}
