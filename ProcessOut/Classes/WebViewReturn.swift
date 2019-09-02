//
//  WebViewReturn.swift
//  Alamofire
//
//  Created by Jeremy Lejoux on 23/07/2019.
//

import Foundation

public class WebViewReturn {
    
    public enum ReturnType {
        case APMAuthorization
        case ThreeDSResult
        case ThreeDSFallbackVerification
    }
    
    public var success: Bool
    public var value: String = ""
    public var type: ReturnType
    public var invoiceId: String = ""
    
    public init(success: Bool, type: ReturnType, value: String) {
        self.success = success
        self.value = value
        self.type = type
    }
    
    public init(success: Bool, type: ReturnType, value: String, invoiceId: String) {
        self.success = success
        self.value = value
        self.type = type
        self.invoideId = invoiceId
    }
    
}
