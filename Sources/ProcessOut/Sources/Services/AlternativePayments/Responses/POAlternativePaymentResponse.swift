//
//  POAlternativePaymentResponse.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

/// Generic alternative payment response.
public struct POAlternativePaymentResponse: Sendable, Codable {

    /// Represents a gateway token.
    ///
    /// - Authorization: The token can be used to capture the payment on your server.
    /// - Tokenization: The token is a gateway request token, which can only be used to
    /// generate the eventual customer token. It should not be used as a payment source.
    public let gatewayToken: String
}
