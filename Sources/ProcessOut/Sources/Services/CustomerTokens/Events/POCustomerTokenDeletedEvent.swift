//
//  POCustomerTokenDeletedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 26.12.2024.
//

import Foundation

@_spi(PO)
public struct POCustomerTokenDeletedEvent: POEventEmitterEvent {

    /// Customer ID that the token was associated with.
    public let customerId: String

    /// Deleted token ID.
    public let tokenId: String
}
