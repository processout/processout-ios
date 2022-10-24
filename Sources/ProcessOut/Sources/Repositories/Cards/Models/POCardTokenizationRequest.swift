//
//  POCardTokenizationRequest.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

public struct POCardTokenizationRequest: Encodable {
    /// Metada related to the card
    public let metadata: [String: AnyEncodable]?

    /// Number of the card
    public let number: String

    /// Expiry month of the card
    public let expMonth: Int

    /// Expiry year of the card
    public let expYear: Int

    /// Card Verification Code of the card
    public let cvc: String?

    /// Name of cardholder
    public let name: String?

    /// Information of cardholder
    public let contact: Contact?

    public init(
        metadata: [String: AnyEncodable]?,
        number: String,
        expMonth: Int,
        expYear: Int,
        cvc: String? = nil,
        name: String? = nil,
        contact: Contact? = nil
    ) {
        self.metadata = metadata
        self.number = number
        self.expMonth = expMonth
        self.expYear = expYear
        self.cvc = cvc
        self.name = name
        self.contact = contact
    }

    /// Information about the user
    public struct Contact: Encodable {
        /// First line of cardholder’s address
        public let address1: String?

        /// Second line of cardholder’s address
        public let address2: String?

        /// City of cardholder’s address
        public let city: String?

        /// State or county of cardholder’s address
        public let state: String?

        /// ZIP code of cardholder’s address
        public let zip: String?

        /// Country code of the delivery address
        public let countryCode: String?

        public init(
            address1: String? = nil,
            address2: String? = nil,
            city: String? = nil,
            state: String? = nil,
            zip: String? = nil,
            countryCode: String? = nil
        ) {
            self.address1 = address1
            self.address2 = address2
            self.city = city
            self.state = state
            self.zip = zip
            self.countryCode = countryCode
        }
    }
}
