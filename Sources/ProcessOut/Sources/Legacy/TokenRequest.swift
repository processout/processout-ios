//
//  TokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

public final class TokenRequest: Encodable {

    var customerID: String = ""
    var tokenID: String = ""
    var source: String = ""
    var verify = true
    var enable3DS2 = true

    public var thirdPartySDKVersion: String = ""
    public var preferredScheme: String = ""

    public init(source: String, customerID: String, tokenID: String) {
        self.source = source
        self.customerID = customerID
        self.tokenID = tokenID
    }

    private enum CodingKeys: String, CodingKey {
        case customerID = "customer_id"
        case tokenID = "token_id"
        case source = "source"
        case verify = "verify"
        case enable3DS2 = "enable_three_d_s_2"
        case thirdPartySDKVersion = "third_party_sdk_version"
        case preferredScheme = "preferred_scheme"
    }
}
