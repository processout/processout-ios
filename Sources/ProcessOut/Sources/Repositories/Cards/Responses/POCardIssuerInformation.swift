//
//  POCardIssuerInformation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

/// Holds information about card issuing institution that issued the card to the card holder.
public struct POCardIssuerInformation: Decodable, Sendable {

    /// Scheme of the card.
    public let scheme: POCardScheme

    /// Co-scheme of the card, such as Carte Bancaire.
    public let coScheme: POCardScheme?

    /// Card type.
    public let type: String?

    /// Name of the card’s issuing bank.
    public let bankName: String?

    /// Brand of the card.
    public let brand: String?

    /// Card category.
    public let category: String?

    @_spi(PO) public init(
        scheme: POCardScheme,
        coScheme: POCardScheme? = nil,
        type: String? = nil,
        bankName: String? = nil,
        brand: String? = nil,
        category: String? = nil
    ) {
        self.scheme = scheme
        self.coScheme = coScheme
        self.type = type
        self.bankName = bankName
        self.brand = brand
        self.category = category
    }
}
