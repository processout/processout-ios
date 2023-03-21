//
//  POCreateCustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 02/11/2022.
//

import Foundation

@_spi(PO)
public struct POCreateCustomerTokenRequest {

    /// Customer id to associate created token with.
    public let customerId: String

    public init(customerId: String) {
        self.customerId = customerId
    }
}
