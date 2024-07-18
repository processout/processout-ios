//
//  POInvoiceRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

/// Request to get single invoice details.
public struct POInvoiceRequest: Sendable {

    /// Requested invoice ID.
    public let id: String

    /// Creates request instance.
    public init(id: String) {
        self.id = id
    }
}
