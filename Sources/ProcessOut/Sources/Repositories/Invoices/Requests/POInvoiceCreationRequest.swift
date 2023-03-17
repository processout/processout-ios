//
//  POInvoiceCreationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.10.2022.
//

import Foundation

@_spi(PO)
public struct POInvoiceCreationRequest: Encodable {

    /// Name of the invoice (often an internal ID code from the merchant’s systems). Maximum 80 characters long.
    public let name: String

    /// Amount to be paid.
    public let amount: String

    /// Currency for payment of the invoice, in ISO 4217 format (for example, USD). Must be a valid
    /// ISO 4217 currency code with 3 characters.
    public let currency: String

    /// For APM, link for the screen you want to return to after the payment page closes.
    public let returnUrl: URL?

    /// Device information.
    public let device: [String: String]

    public init(name: String, amount: String, currency: String, returnUrl: URL? = nil) {
        self.name = name
        self.amount = amount
        self.currency = currency
        self.returnUrl = returnUrl
        self.device = ["channel": "ios"]
    }
}
