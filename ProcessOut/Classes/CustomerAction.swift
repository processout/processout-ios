//
//  CustomerAction.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

public class CustomerAction: Codable {
    
    public enum CustomerActionType: String, Codable {
        case fingerPrintMobile = "fingerprint-mobile"
        case challengeMobile = "challenge-mobile"
        case url = "url"
        case redirect = "redirect"
        case fingerprint = "fingerprint"
    }
    
    public var type: CustomerActionType = CustomerActionType.redirect
    public var value: String = ""
    
    enum CodingKeys: String, CodingKey {
        case type = "type"
        case value = "value"
    }
}
