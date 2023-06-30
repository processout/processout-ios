//
//  POCardIssuerInformation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

/// Holds information about card issuing institution that issued the card to the card holder.
public struct POCardIssuerInformation: Decodable {

    /// Scheme of the card.
    public let scheme: String

    /// Co-scheme of the card, such as Carte Bancaire.
    public let coScheme: String?

    /// Card type.
    public let type: String?

    /// Name of the card’s issuing bank.
    public let bankName: String?

    /// Brand of the card.
    public let brand: String?

    /// Card category.
    public let category: String?
}
