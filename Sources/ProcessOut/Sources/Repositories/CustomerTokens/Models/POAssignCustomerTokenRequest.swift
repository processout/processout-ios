//
//  POAssignCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 27/10/2022.
//

import Foundation

public struct POAssignCustomerTokenRequest: Encodable {

    /// Invoice identifier to to perform authorization for.
    @ImmutableExcludedCodable
    public var customerId: String

    /// Payment source to use for authorization.
    public let source: String

    /// Boolean value indicating whether 3DS2 is enabled.
    public let enableThreeDS2: Bool?

    /// Card scheme or co-scheme that should get priority if it is available.
    public let preferredScheme: String?

    /// Can be used for a 3DS2 request to indicate which third party SDK is used for the call.
    public let thirdPartySdkVersion: String?

    /// Verification of the token.
    public let verify: Bool?

    /// Tokens that belong to the customer.
    @ImmutableExcludedCodable
    public var tokenId: String

    public init(
        customerId: String,
        source: String,
        enableThreeDS2: Bool? = nil,
        preferredScheme: String? = nil,
        thirdPartySdkVersion: String? = nil,
        verify: Bool? = nil,
        tokenId: String
    ) {
        self._customerId = .init(value: customerId)
        self.source = source
        self.enableThreeDS2 = enableThreeDS2
        self.preferredScheme = preferredScheme
        self.thirdPartySdkVersion = thirdPartySdkVersion
        self.verify = verify
        self._tokenId = .init(value: tokenId)
    }
}
