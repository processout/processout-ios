//
//  TokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

class TokenRequest: Encodable {
    var customerID: String = ""
    var tokenID: String = ""
    var source: String = ""
    var verify = true
    var enable3DS2 = true
    var thirdPartySDKVersion: String = ""
    var preferredScheme: String = ""
    enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case tokenID = "token_id"
        case source = "source"
        case verify = "verify"
        case enable3DS2 = "enable_three_d_s_2"
        case thirdPartySDKVersion = "third_party_sdk_version"
        case preferredScheme = "preferred_scheme"
    }
    
    init(source: String, thirdPartySDKVersion: String) {
        self.source = source
        self.thirdPartySDKVersion = thirdPartySDKVersion
    }
}
