//
//  AuthentificationChallengeData.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

public class AuthentificationChallengeData: Codable {
    public var acsTransID: String
    public var acsReferenceNumber: String
    public var acsSignedContent: String
    public var threeDSServerTransID: String
    
    private enum CodingKeys: String, CodingKey {
        case acsTransID = "acsTransID"
        case acsReferenceNumber = "acsReferenceNumber"
        case acsSignedContent = "acsSignedContent"
        case threeDSServerTransID = "threeDSServerTransID"
    }
    
    init(acsTransID: String, acsReferenceNumber: String, acsSignedContent: String, threeDSServerTransID: String) {
        self.acsTransID = acsTransID
        self.acsReferenceNumber = acsReferenceNumber
        self.acsSignedContent = acsSignedContent
        self.threeDSServerTransID = threeDSServerTransID
    }
}
