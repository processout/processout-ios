//
//  ApplePayCardTokenizationRequestMapperType.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

protocol ApplePayCardTokenizationRequestMapperType {

    /// Creates tokenization request with given ``POApplePayCardTokenizationRequest`` instance.
    func tokenizationRequest(from request: POApplePayCardTokenizationRequest) throws -> ApplePayCardTokenizationRequest
}
