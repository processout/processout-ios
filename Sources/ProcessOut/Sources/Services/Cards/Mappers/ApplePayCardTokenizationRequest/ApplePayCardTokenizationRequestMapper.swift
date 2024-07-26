//
//  ApplePayCardTokenizationRequestMapper.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

protocol ApplePayCardTokenizationRequestMapper: Sendable {

    /// Creates tokenization request with given ``POApplePayCardTokenizationRequest`` instance.
    func tokenizationRequest(
        from request: POApplePayCardTokenizationRequest
    ) async throws -> ApplePayCardTokenizationRequest
}
