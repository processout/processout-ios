//
//  POCustomerTokenType.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.04.2025.
//

/// Customer token type.
public enum POCustomerTokenType: String, Hashable, Sendable {

    /// Card token
    case card

    /// Gateway token.
    case gateway = "gateway_token"
}
