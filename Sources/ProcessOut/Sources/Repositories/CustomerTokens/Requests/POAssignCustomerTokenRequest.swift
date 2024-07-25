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
    public let customerId: String // sourcery:coding: skip

    /// Tokens that belong to the customer.
    public let tokenId: String // sourcery:coding: skip

    /// Payment source to associate with token. The source can be a card, an APM or a gateway request. For the source
    /// to be valid, you must not have used it for any previous payment or to create any other customer tokens.
    public let source: String

    /// Card scheme or co-scheme that should get priority if it is available.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var preferredScheme: String?

    /// Boolean value that indicates whether token should be verified. Make sure to also pass valid
    /// ``POAssignCustomerTokenRequest/invoiceId`` if you want verification to happen. Default value
    /// is `false`.
    public let verify: Bool

    /// Invoice identifier that will be used for token verification.
    public let invoiceId: String?

    /// Boolean value used as flag that when set to `true` indicates that a request is coming directly
    /// from the frontend.  It is used to understand if we can instantly step-up to 3DS or not.
    ///
    /// Value is hardcoded to `true`.
    @available(*, deprecated, message: "Property is an implementation detail and shouldn't be used.")
    public let enableThreeDS2 = true // sourcery:coding: key="enable_three_d_s_2"

    /// Can be used for a 3DS2 request to indicate which third party SDK is used for the call.
    public let thirdPartySdkVersion: String?

    /// Additional metadata.
    public let metadata: [String: String]?

    /// Creates request instance.
    public init(
        customerId: String,
        tokenId: String,
        source: String,
        preferredScheme: String? = nil,
        verify: Bool = false,
        invoiceId: String? = nil,
        enableThreeDS2 _: Bool = true,
        thirdPartySdkVersion: String? = nil,
        metadata: [String: String]? = nil
    ) {
        self.customerId = customerId
        self.tokenId = tokenId
        self.source = source
        self._preferredScheme = .init(wrappedValue: preferredScheme)
        self.verify = verify
        self.invoiceId = invoiceId
        self.thirdPartySdkVersion = thirdPartySdkVersion
        self.metadata = metadata
    }
}
