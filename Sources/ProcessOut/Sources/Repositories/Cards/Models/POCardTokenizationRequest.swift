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

    /// Information about the card's user
    public let card: Card

    /// Card details
    public struct Card: Encodable {
        let cardNumber: String
        let expMonth: Int
        let expYear: Int
        let cvc: String?
        let name: String
        let contact: Contact?

        public init(cardNumber: String, expMonth: Int, expYear: Int, cvc: String?, name: String, contact: Contact?) {
            self.cardNumber = cardNumber
            self.expMonth = expMonth
            self.expYear = expYear
            self.cvc = cvc
            self.name = name
            self.contact = contact
        }
    }

    /// Information about the user
    public struct Contact: Encodable {
        let address1: String?
        let address2: String?
        let city: String?
        let state: String?
        let zip: String?
        let countryCode: String?

        public init(
            address1: String?,
            address2: String?,
            city: String?,
            state: String?,
            zip: String?,
            countryCode: String?
        ) {
            self.address1 = address1
            self.address2 = address2
            self.city = city
            self.state = state
            self.zip = zip
            self.countryCode = countryCode
        }
    }

    /// init the tokenization of the card
    public init(card: Card, metadata: [String: AnyEncodable]?) {
        self.card = card
        self.metadata = metadata
    }
}
