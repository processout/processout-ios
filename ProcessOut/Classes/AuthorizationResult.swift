//
//  AuthorizationResult.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

class AuthorizationResult: ApiResponse {
    public class CustomerAction: Codable {
        
        enum CustomerActionType: String, Codable {
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
    
    public var customerAction: CustomerAction?
    
    private enum CodingKeys: String, CodingKey {
        case customerAction = "customer_action"
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.customerAction = try container.decodeIfPresent(CustomerAction.self, forKey: .customerAction)
        try super.init(from: decoder)
    }
}
