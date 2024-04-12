//
//  POLogAttributeKey.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.04.2024.
//

import Foundation

@_spi(PO)
public struct POLogAttributeKey: RawRepresentable, ExpressibleByStringLiteral, Hashable {

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
    public static let gatewayConfigurationId: Self = "GatewayConfigurationId"

    /// Card ID.
    public static let cardId: Self = "CardId"

    /// Invoice ID.
    public static let invoiceId: Self = "InvoiceId"
}
