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

    public init(customerId: String, verify: Bool = false) {
        self._customerId = .init(value: customerId)
        self.verify = verify
    }
}
