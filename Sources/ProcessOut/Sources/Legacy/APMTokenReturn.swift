//
//  APMTokenReturn.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 31/10/2019.
//

import Foundation

public final class APMTokenReturn {

    public enum APMReturnType {
        case Authorization
        case CreateToken
    }
    
    public var token: String?
    public var customerId: String?
    public var tokenId: String?
    public var returnType: APMReturnType
    public var error: ProcessOutException?
    
    public init(token: String) {
        self.token = token
        self.returnType = .Authorization
    }
    
    public init(token: String, customerId: String, tokenId: String) {
        self.token = token
        self.customerId = customerId
        self.tokenId = tokenId
        self.returnType = .CreateToken
    }
    
    public init(error: ProcessOutException) {
        self.error = error
        self.returnType = .Authorization
    }
}
