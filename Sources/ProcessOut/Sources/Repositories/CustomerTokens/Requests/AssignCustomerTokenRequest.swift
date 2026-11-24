//
//  AssignCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2026.
//

struct AssignCustomerTokenRequest: Encodable, Sendable { // sourcery: AutoCodingKeys

    /// Id of the customer who token belongs to.
    let customerId: String // sourcery:coding: skip

    /// Token that belongs to the customer.
    let tokenId: String // sourcery:coding: skip

    /// Payment source to associate with token.
    let source: String

    /// Card scheme or co-scheme that should get priority if it is available.
    let preferredScheme: POCardScheme?

    /// Boolean value that indicates whether token should be verified.
    let verify: Bool

    /// Invoice identifier that will be used for token verification.
    let invoiceId: String?

    /// Indicates that request is coming directly from the frontend, so it is possible to instantly step-up to 3DS.
    let enableThreeDS2 = true // sourcery:coding: key="enable_three_d_s_2"

    /// Third party SDK version that is used to handle 3DS2.
    let thirdPartySdkVersion: String?

    /// Additional metadata.
    let metadata: [String: String]?

    /// Customer's locale identifier override.
    let localeIdentifier: String? // sourcery:coding: skip
}
