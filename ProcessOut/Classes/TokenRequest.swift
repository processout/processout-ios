//
//  TokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

class TokenRequest: Encodable {
    var source: String = ""
    
    enum CodingKeys: String, CodingKey {
        case source = "source"
    }
    
    init(source: String) {
        self.source = source
    }
}
