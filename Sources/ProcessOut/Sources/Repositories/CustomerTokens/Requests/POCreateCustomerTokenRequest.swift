//
//  POCreateCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCreateCustomerTokenRequest: Encodable, Sendable {

    /// Customer id to associate created token with.
    @POImmutableExcludedCodable
    public var customerId: String

    /// Flag if you wish to verify the customer token by making zero value transaction. Applicable for cards only.
    public let verify: Bool

    /// Return URL to assign to verification invoice.
    public let invoiceReturnUrl: URL?

    public init(customerId: String, verify: Bool = false, invoiceReturnUrl: URL? = nil) {
        self._customerId = .init(value: customerId)
        self.verify = verify
        self.invoiceReturnUrl = invoiceReturnUrl
    }
}
