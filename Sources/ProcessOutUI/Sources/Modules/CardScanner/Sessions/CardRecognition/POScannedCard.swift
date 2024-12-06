//
//  POScannedCard.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

@_spi(PO)
public struct POScannedCard: Sendable, Hashable {

    public struct Expiration: Sendable, Hashable, CustomStringConvertible {

        /// Expiration month.
        public let month: Int

        /// Expiration year as a four digits number.
        public let year: Int

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
