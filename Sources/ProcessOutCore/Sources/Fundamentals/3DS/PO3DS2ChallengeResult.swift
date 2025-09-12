//
//  PO3DS2ChallengeResult.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 01.08.2024.
//

/// Contains information about completion of the challenge process.
@available(iOS 15, *)
@_originallyDefinedIn(module: "ProcessOut", iOS 15)
public struct PO3DS2ChallengeResult: Codable, Sendable {

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
