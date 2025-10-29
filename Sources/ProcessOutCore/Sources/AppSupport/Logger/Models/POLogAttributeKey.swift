//
//  POLogAttributeKey.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.04.2024.
//

import Foundation

package struct POLogAttributeKey: RawRepresentable, ExpressibleByStringLiteral, Hashable, Sendable {

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }

    public let rawValue: String
}

extension POLogAttributeKey {

    /// Gateway configuration ID.
    package static let gatewayConfigurationId: Self = "GatewayConfigurationId"

    /// Card ID.
    package static let cardId: Self = "CardId"

    /// Invoice ID.
    package static let invoiceId: Self = "InvoiceId"

    /// Invoice ID.
    package static let customerId: Self = "CustomerId"

    /// Invoice ID.
    package static let customerTokenId: Self = "CustomerTokenId"
}
