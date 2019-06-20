//
//  MiscGatewayRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

class MiscGatewayRequest: Codable {
    var url: String = ""
    var headers: [String:String] = [:]
    var body: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case url = "url"
        case headers = "headers"
        case body = "body"
    }
    
    public init(fingerprintResponse: String) {
        self.body = fingerprintResponse
    }
}
