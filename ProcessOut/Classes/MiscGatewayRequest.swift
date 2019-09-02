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
    
    
    /// Generate corresponding gateway token
    ///
    /// - Returns: The corresponding gateway token, nil if an error occured
    public func generateToken() -> String? {
        do {
            let encodedJson = try JSONEncoder().encode(self)
            if let base64Encoded = String(data: encodedJson.base64EncodedData(), encoding: .utf8) {
                return "gway_req_" + base64Encoded
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
}
