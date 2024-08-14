//
//  POTransaction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2024.
//

import Foundation

/// Transaction details.
@_spi(PO)
public struct POTransaction: Decodable, Sendable {

    /// Transaction status.
    public let status: POTransactionStatus?
}
