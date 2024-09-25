//
//  PO3DS2ChallengeResult.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

/// Contains information about completion of the challenge process.
public struct PO3DS2ChallengeResult: Encodable, Sendable {

    /// The transaction status that was received in the final challenge response.
    public let transactionStatus: String

    public init(transactionStatus: String) {
        self.transactionStatus = transactionStatus
    }

    public init(transactionStatus: Bool) {
        self.transactionStatus = transactionStatus ? "Y" : "N"
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case transactionStatus = "transStatus"
    }
}
