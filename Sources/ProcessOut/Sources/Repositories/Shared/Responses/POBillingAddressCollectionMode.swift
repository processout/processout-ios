//
//  POBillingAddressCollectionMode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.05.2024.
//

/// Billing address collection modes.
public enum POBillingAddressCollectionMode: String, Codable, Sendable {

    /// Only collect address components that are needed for particular payment method.
    case automatic

    /// Never collect address.
    case never

    /// Collect the full billing address.
    case full
}
