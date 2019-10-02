//
//  CustomerRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

public class CustomerRequest: Encodable {
    
    var firstName: String = ""
    var lastName: String = ""
    var currency: String = ""
    
    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case currency = "currency"
    }
    
    public init(firstName: String, lastName: String, currency: String) {
        self.firstName = firstName
        self.lastName = lastName
        self.currency = currency
    }
}
