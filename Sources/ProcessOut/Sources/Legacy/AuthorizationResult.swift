//
//  AuthorizationResult.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

@available(*, deprecated)
final class AuthorizationResult: ApiResponse {    

    var customerAction: CustomerAction?
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.customerAction = try container.decodeIfPresent(CustomerAction.self, forKey: .customerAction)
        try super.init(from: decoder)
    }

    private enum CodingKeys: String, CodingKey {
        case customerAction = "customer_action"
    }
}
