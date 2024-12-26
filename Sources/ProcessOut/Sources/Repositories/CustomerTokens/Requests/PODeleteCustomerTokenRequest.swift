//
//  PODeleteCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.12.2024.
//

public struct PODeleteCustomerTokenRequest {

    /// ID of your customer
    public let customerId: String

    /// ID of the customer token.
    public let tokenId: String

    /// A secret key associated with the client making the request.
    public let clientSecret: String

    public init(customerId: String, tokenId: String, clientSecret: String) {
        self.customerId = customerId
        self.tokenId = tokenId
        self.clientSecret = clientSecret
    }
}
