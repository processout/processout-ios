//
//  POTransaction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2024.
//

import Foundation

/// Transaction details.
public struct POTransaction: Codable, Sendable {

    /// Transaction status.
    public let status: POTransactionStatus?
}
