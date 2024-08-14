//
//  POTransactionStatus.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.08.2024.
//

/// Transaction status.
@_spi(PO)
public struct POTransactionStatus: RawRepresentable, Sendable, Hashable {

    /// Raw status.
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension POTransactionStatus: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

extension POTransactionStatus {

    /// Waiting transaction.
    public static let waiting = POTransactionStatus(rawValue: "waiting")

    /// Pending transaction.
    public static let pending = POTransactionStatus(rawValue: "pending")

    /// Pending capture transaction.
    public static let pendingCapture = POTransactionStatus(rawValue: "pending-capture")

    /// Failed transaction.
    public static let failed = POTransactionStatus(rawValue: "failed")

    /// Voided transaction.
    public static let voided = POTransactionStatus(rawValue: "voided")

    /// State of a chargeback transaction where the chargeback outcome hasn't been defined
    /// yet (can still be won or lost).
    public static let chargebackInitiated = POTransactionStatus(rawValue: "chargeback-initiated")

    /// Reversed transaction.
    public static let transactionReversed = POTransactionStatus(rawValue: "reversed")

    /// Partially refunded transaction.
    public static let partiallyRefunded = POTransactionStatus(rawValue: "partially-refunded")

    /// Refunded transaction.
    public static let refunded = POTransactionStatus(rawValue: "refunded")

    /// Solved transaction.
    public static let solved = POTransactionStatus(rawValue: "solved")

    /// Authorized transaction.
    public static let authorized = POTransactionStatus(rawValue: "authorized")

    /// Completed transaction.
    public static let completed = POTransactionStatus(rawValue: "completed")

    /// State of a transaction that has been asked for information
    /// retrieval request (part of chargeback process).
    public static let retrievalRequest = POTransactionStatus(rawValue: "retrieval-request")

    /// Transaction has been flagged as fraud by issuer.
    public static let fraudNotification = POTransactionStatus(rawValue: "fraud-notification")

    /// Transaction was blocked by the merchant or an anti fraud solution.
    public static let blocked = POTransactionStatus(rawValue: "blocked")

    /// Transaction is in a anti-fraud review state
    public static let inReview = POTransactionStatus(rawValue: "in-review")
}
