//
//  POCardTokenizationResponse.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

public struct POCardTokenizationResponse: Decodable {

    let card: POCard

    public struct POCard: Decodable {
        /// Value that uniquely identifies the card
        public let id: String

        /// Project that the card belongs to
        public let projectId: String

        /// Scheme of the card, such as Visa or Mastercard
        public let scheme: String

        /// Co-scheme of the card, such as Carte Bancaire
        public let coScheme: String?

        /// Preferred scheme defined by the Customer
        public let preferredScheme: String?

        /// Card type (debit or credit)
        public let type: String

        /// Name of the card’s issuing bank
        public let bankName: String

        /// Brand of the card, such as Electron, Classic or Gold
        public let brand: String

        /// Card category (consumer or commercial)
        public let category: String

        /// Issuer identification number. Corresponds to the first 6 or 8 digits of the main card number.
        public let iin: String

        /// Last 4 digits of the card
        public let last4Digits: String

        /// Hash value that remains the same for this card even if it is tokenized several times
        public let fingerprint: String

        /// Month of the expiration date
        public let expMonth: Int

        /// Year of the expiration date
        public let expYear: Int

        /// CVC check status
        public let cvcCheck: String

        /// AVS check status
        public let avsCheck: String

        /// Contains the name of a third party tokenization method
        public let tokenType: String?

        /// Cardholder’s name
        public let name: String

        /// First line of cardholder’s address
        public let address1: String?

        /// Second line of cardholder’s address
        public let address2: String?

        /// City of cardholder’s address
        public let city: String?

        /// State or county of cardholder’s address
        public let state: String?

        /// Country code of cardholder’s address
        public let countryCode: String

        /// ZIP code of cardholder’s address
        public let zip: String

        /// IP address of the cardholder
        public let ipAddress: String

        /// Value of the User-Agent header of the cardholder
        public let userAgent: String?

        /// Value of the Accept header of the cardholder
        public let headerAccept: String?

        /// Supported color depth on the cardholder’s screen, if one is available
        public let appColorDepth: String?

        /// Denotes whether or not Java is enabled on the cardholder device
        public let appJavaEnabled: Bool?

        /// Language of the cardholder’s device, if available
        public let appLanguage: String?

        /// Height in pixels of the cardholder’s screen
        public let appScreenHeight: Int?

        /// Width in pixels of the cardholder’s screen
        public let appScreenWidth: Int?

        /// Timezone offset of the cardholder
        public let appTimezoneOffset: Int

        /// Set to true if the card will expire soon, otherwise false
        public let expiresSoon: Bool

        /// Metadata related to the card, in the form of key-value pairs
        public let metadata: [String: String]

        /// Denotes whether or not this card was created in the sandbox testing environment
        public let sandbox: String

        /// Date and time when this card was created
        public let createdAt: Date

        /// Type of card update
        public let updateType: String?
    }
}
