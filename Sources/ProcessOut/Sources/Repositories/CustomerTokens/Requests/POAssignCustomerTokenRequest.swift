//
//  POAssignCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

/// Request to use to assign new source to existing customer token and potentially verify it.
public struct POAssignCustomerTokenRequest: Encodable { // sourcery: AutoCodingKeys

    /// Id of the customer who token belongs to.
    @POImmutableExcludedCodable
    public var customerId: String

    /// Tokens that belong to the customer.
    @POImmutableExcludedCodable
    public var tokenId: String

    /// Payment source to associate with token. The source can be a card, an APM or a gateway request. For the source
    /// to be valid, you must not have used it for any previous payment or to create any other customer tokens.
    public let source: String

    /// Card scheme or co-scheme that should get priority if it is available.
    public let preferredScheme: String?

    /// Boolean value that indicates whether token should be verified. Make sure to also pass valid
    /// ``POAssignCustomerTokenRequest/invoiceId`` if you want verification to happen. Default value
    /// is `false`.
    public let verify: Bool

    /// Invoice identifier that will be used for token verification.
    public let invoiceId: String?

    /// Boolean value indicating whether 3DS2 is enabled. Default value is `true`.
    public let enableThreeDS2: Bool

    /// Can be used for a 3DS2 request to indicate which third party SDK is used for the call.
    public let thirdPartySdkVersion: String?

    /// Additional matadata.
    public let metadata: [String: String]?

    /// Creates request instance.
    public init(
        customerId: String,
        tokenId: String,
        source: String,
        preferredScheme: String? = nil,
        verify: Bool = false,
        invoiceId: String? = nil,
        enableThreeDS2: Bool = true,
        thirdPartySdkVersion: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self._customerId = .init(value: customerId)
        self._tokenId = .init(value: tokenId)
        self.source = source
        self.preferredScheme = preferredScheme
        self.verify = verify
        self.invoiceId = invoiceId
        self.enableThreeDS2 = enableThreeDS2
        self.thirdPartySdkVersion = thirdPartySdkVersion
        self.metadata = metadata
    }
}
