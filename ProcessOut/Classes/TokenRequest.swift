//
//  TokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

class TokenRequest: Encodable {
    var source: String = ""
    var verify = true
    var enable3DS2 = true
    enum CodingKeys: String, CodingKey {
        case source = "source"
        case verify = "verify"
        case enable3DS2 = "enable_three_d_s_2"
    }
    
    init(source: String) {
        self.source = source
    }
}
