//
//  CustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

public class CustomerTokenRequest: Encodable {
    var source: String = ""
    var verify: Bool = true
    var threeDS2Enabled = true
    
    enum CodingKeys: String, CodingKey {
        case source = "source"
        case verify = "verify"
        case threeDS2Enabled = "enable_three_d_s_2"
    }
    
    public init(source: String) {
        self.source = source
    }
}
