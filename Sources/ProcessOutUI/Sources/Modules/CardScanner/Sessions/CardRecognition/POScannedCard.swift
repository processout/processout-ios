//
//  POScannedCard.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

/// Scanned card details.
public struct POScannedCard: Sendable, Hashable {

    public struct Expiration: Sendable, Hashable, CustomStringConvertible {

        /// Expiration month.
        public let month: Int

        /// Expiration year as a four digits number.
        public let year: Int

        /// A Boolean value that indicates whether the card's expiration date has passed, making the card expired.
        public let isExpired: Bool

        /// Formatted description.
        public let description: String
    }

    /// Recognized card number.
    public let number: String

    /// Expiration month and year.
    public let expiration: Expiration?

    /// Cardholder name.
    public let cardholderName: String?
}
