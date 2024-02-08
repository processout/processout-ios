//
//  POCards.swift
//  ProcessOut
//
//  Created by Julien.Rodrigues on 24/10/2022.
//

import Foundation

/// A card object represents a credit or debit card. It contains many useful pieces of information about the card but
/// it does not contain the full card number and CVC (which are kept securely in the ProcessOut Vault).
public struct POCard: Decodable, Hashable {

    /// Value that uniquely identifies the card.
    public let id: String

    /// Project that the card belongs to.
    public let projectId: String

    /// Scheme of the card.
    public let scheme: String

    /// Co-scheme of the card, such as Carte Bancaire.
    public let coScheme: String?

    /// Preferred scheme defined by the Customer.
    public let preferredScheme: String?

    /// Card type.
    public let type: String

    /// Name of the card’s issuing bank.
    public let bankName: String?

    /// Brand of the card.
    public let brand: String?

    /// Card category.
    public let category: String?

    /// Issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
    public let iin: String

    /// Last 4 digits of the card.
    public let last4Digits: String

    /// Hash value that remains the same for this card even if it is tokenized several times.
    /// - NOTE: fingerprint is empty string for Apple and Google Pay cards.
    @POFallbackDecodable<POEmptyStringProvider>
    public private(set) var fingerprint: String

    /// Month of the expiration date.
    public let expMonth: Int

    /// Year of the expiration date.
    public let expYear: Int

    /// CVC check status.
    public let cvcCheck: POCardCvcCheck

    /// AVS check status.
    public let avsCheck: String

    /// Contains the name of a third party tokenization method.
    public let tokenType: String?

    /// Cardholder’s name.
    public let name: String?

    /// First line of cardholder’s address.
    public let address1: String?

    /// Second line of cardholder’s address.
    public let address2: String?

    /// City of cardholder’s address.
    public let city: String?

    /// State or county of cardholder’s address.
    public let state: String?

    /// Country code of cardholder’s address.
    public let countryCode: String?

    /// ZIP code of cardholder’s address.
    public let zip: String?

    /// Set to true if the card will expire soon, otherwise false.
    public let expiresSoon: Bool

    /// Metadata related to the card, in the form of key-value pairs.
    public let metadata: [String: String]

    /// Denotes whether or not this card was created in the sandbox testing environment.
    public let sandbox: Bool

    /// Date and time when this card was created.
    public let createdAt: Date

    /// Type of card update.
    public let updateType: String?
}
