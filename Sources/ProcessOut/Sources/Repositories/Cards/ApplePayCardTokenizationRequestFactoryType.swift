//
//  ApplePayCardTokenizationRequestFactoryType.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 25/10/2022.
//

import Foundation

protocol ApplePayCardTokenizationRequestFactoryType {
    /// Creates tokenization request with given ``POApplePayCardTokenizationRequest`` instance.
    func tokenizationRequest(from request: POApplePayCardTokenizationRequest) throws -> ApplePayCardTokenizationRequest
}
