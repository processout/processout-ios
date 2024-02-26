//
//  POScannedCard.swift
//  vision-test
//
//  Created by Andrii Vysotskyi on 26.01.2024.
//

public struct POScannedCard {

    /// Recognized card number.
    public let number: String

    /// Expiration month and year.
    public let expiration: String?

    /// Cardholder name.
    public let cardholder: String?
}
