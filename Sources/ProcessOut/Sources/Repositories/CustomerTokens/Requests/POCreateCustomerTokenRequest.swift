//
//  POCreateCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCreateCustomerTokenRequest: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Customer id to associate created token with.
    public let customerId: String // sourcery:coding: skip

    /// Flag if you wish to verify the customer token by making zero value transaction. Applicable for cards only.
    public let verify: Bool

    /// Return URL to assign to verification invoice.
    public let invoiceReturnUrl: URL?

    public init(customerId: String, verify: Bool = false, invoiceReturnUrl: URL? = nil) {
        self.customerId = customerId
        self.verify = verify
        self.invoiceReturnUrl = invoiceReturnUrl
    }
}
