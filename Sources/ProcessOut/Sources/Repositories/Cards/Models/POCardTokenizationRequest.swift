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
    public let number: String
    public let expMonth: Int
    public let expYear: Int
    public let cvc: String?
    public let name: String
    public let contact: Contact?

    public init(
        metadata: [String: AnyEncodable]?,
        number: String,
        expMonth: Int,
        expYear: Int,
        cvc: String?,
        name: String,
        contact: Contact?
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
        public let address1: String?
        public let address2: String?
        public let city: String?
        public let state: String?
        public let zip: String?
        public let countryCode: String?

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
}
