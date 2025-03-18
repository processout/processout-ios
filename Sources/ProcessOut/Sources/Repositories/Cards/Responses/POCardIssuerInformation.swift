//
//  POCardIssuerInformation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

/// Holds information about card issuing institution that issued the card to the card holder.
public struct POCardIssuerInformation: Codable, Sendable {

    /// Scheme of the card.
    @POTypedRepresentation<String, POCardScheme>
    public private(set) var scheme: String

    /// Co-scheme of the card, such as Carte Bancaire.
    @POTypedRepresentation<String?, POCardScheme>
    public private(set) var coScheme: String?

    /// Card type.
    public let type: String?

    /// Name of the card’s issuing bank.
    public let bankName: String?

    /// Brand of the card.
    public let brand: String?

    /// Card category.
    public let category: String?

    @_spi(PO)
    public init(
        scheme: POCardScheme,
        coScheme: POCardScheme? = nil,
        type: String? = nil,
        bankName: String? = nil,
        brand: String? = nil,
        category: String? = nil
    ) {
        self._scheme = .init(wrappedValue: scheme.rawValue)
        self._coScheme = .init(wrappedValue: coScheme?.rawValue)
        self.type = type
        self.bankName = bankName
        self.brand = brand
        self.category = category
    }
}
