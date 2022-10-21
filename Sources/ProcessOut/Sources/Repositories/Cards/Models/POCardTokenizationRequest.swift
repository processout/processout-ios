//
//  File.swift
//  
//
//  Created by Julien.Rodrigues on 20/10/2022.
//

import Foundation

public struct POCardsRequest: Encodable {
    public let metadata: [String: AnyEncodable]?
    
    public let card: Card
    
    public struct Card: Encodable {
        let CardNumber: String
        let ExpMonth: Int
        let ExpYear: Int
        let CVC: String?
        let Name: String
        let Contact: Contact?
            
        public init(cardNumber: String, expMonth: Int, expYear: Int, cvc: String?, name: String, contact: Contact) {
            self.CardNumber = cardNumber
            self.ExpMonth = expMonth
            self.ExpYear = expYear
            self.CVC = cvc
            self.Name = name
            self.Contact = contact
        }
    }

    public struct Contact: Encodable {
        let Address1: String?
        let Address2: String?
        let City: String?
        let State: String?
        let Zip: String?
        let CountryCode: String?
        
        public init(address1: String?, address2: String?, city: String?, state: String?, zip: String?, countryCode: String?) {
            self.Address1 = address1
            self.Address2 = address2
            self.City = city
            self.State = state
            self.Zip = zip
            self.CountryCode = countryCode
        }
    }

    public init(card: Card, metadata: [String: AnyEncodable]?) {
        self.card = card
        self.metadata = metadata
    }
}


