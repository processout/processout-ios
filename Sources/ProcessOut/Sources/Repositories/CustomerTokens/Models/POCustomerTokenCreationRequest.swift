//
//  POCustomerTokenCreationRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCustomerTokenCreationRequest: Encodable {

    /// Payment source to use for authorization.
    public let source: String

    /// Invoice identifier to to perform authorization for.
    @POImmutableExcludedCodable
    public var customerId: String

    /// Additional matadata.
    public let metadata: [String: POAnyEncodable]

    public init(
        source: String,
        customerId: String,
        metadata: [String: POAnyEncodable]
    ) {
        self.source = source
        self._customerId = .init(value: customerId)
        self.metadata = metadata
    }
}
