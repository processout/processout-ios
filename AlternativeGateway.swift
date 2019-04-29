//
//  AlternativeGateway.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/04/2019.
//

import Foundation

public class AlternativeGateway: Decodable {
    public struct Gateway: Decodable {
        
        enum CodingKeys: String, CodingKey {
            case displayName = "display_name"
            case logoUrl = "logo_url"
            case tags = "tags"
            case name = "name"
        }
        
        public var name: String?
        public var displayName: String
        public var logoUrl: String?
        public var tags: [String]
    }
    
    public var id: String
    public var name: String?
    public var enabled: Bool
    public var gateway: Gateway?

    required init(id: String, name: String, enabled: Bool, gateway: Gateway) {
        self.id = id
        self.name = name
        self.enabled = enabled
        self.gateway = gateway
    }
    
    public func getRedirectURL(invoiceId: String) -> NSURL? {
        let checkout = ProcessOut.ProjectId! + "/" + invoiceId + "/redirect/" + self.id
        if let url = NSURL(string: ProcessOut.CheckoutUrl + "/" + checkout) {
            return url
        }
        return nil
    }
}
