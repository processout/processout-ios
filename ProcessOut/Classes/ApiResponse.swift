//
//  ApiResponse.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

class ApiResponse: Decodable {
    var success: Bool
    var message: String?
    var errorType: String?
    
    private enum CodingKeys: String, CodingKey {
        case success = "success"
        case message = "message"
        case errorType = "error_type"
    }
}
