//
//  POCustomer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 19.12.2024.
//

@_spi(PO)
public struct POCustomer: Decodable, Sendable {

    /// Customer ID.
    public let id: String
}
