//
//  POScannedCard.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.11.2024.
//

public struct POScannedCard: Sendable {

    /// Recognized card number.
    public let number: String

    /// Expiration month and year.
    public let expiration: String?

    /// Cardholder name.
    public let cardholder: String?
}
