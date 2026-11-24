//
//  PODeleteCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.12.2024.
//

/// Request to use to remove existing customer token.
public struct PODeleteCustomerTokenRequest: Sendable, Codable {

    /// ID of your customer
    public let customerId: String

    /// ID of the customer token.
    public let tokenId: String

    /// A secret key associated with the client making the request.
    public let clientSecret: String

    /// Customer's locale identifier override.
    @POExcludedEncodable
    public private(set) var localeIdentifier: String?

    public init(customerId: String, tokenId: String, clientSecret: String, localeIdentifier: String? = nil) {
        self.customerId = customerId
        self.tokenId = tokenId
        self.clientSecret = clientSecret
        self.localeIdentifier = localeIdentifier
    }
}
