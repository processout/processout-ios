//
//  CustomerTokenRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 19/09/2019.
//

import Foundation

public class CustomerTokenRequest: Encodable {
    var source: String = ""
    
    enum CodingKeys: String, CodingKey {
        case source = "source"
    }
    
    public init(source: String) {
        self.source = source
    }
}
