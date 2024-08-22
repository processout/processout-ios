//
//  POCreateCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCreateCustomerTokenRequest: Encodable {

    /// Customer id to associate created token with.
    @POImmutableExcludedCodable
    public var customerId: String

    /// Flag if you wish to verify the customer token by making zero value transaction. Applicable for cards only.
    public let verify: Bool

    /// For APMs, this is the URL to return to the app after payment is accepted.
    public let returnUrl: URL?

    /// This is the URL to be set on the invoice that is created for card verification.
    public let invoiceReturnUrl: URL?

    public init(customerId: String, verify: Bool = false, returnUrl: URL? = nil) {
        self._customerId = .init(value: customerId)
        self.verify = verify
        self.returnUrl = returnUrl
        self.invoiceReturnUrl = returnUrl
    }
}
