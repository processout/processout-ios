//
//  ThreeDSFingerprintResponse.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

public class ThreeDSFingerprintResponse: Codable {
    
    public class SDKEphemPubKey: Codable {
        var crv: String = ""
        var kty: String = ""
        var x: String = ""
        var y: String = ""
        
        private enum CodingKeys: String, CodingKey {
            case crv = "crv"
            case kty = "kty"
            case x = "x"
            case y = "y"
        }
    }
    
    var sdkEncData: String = ""
    var deviceChannel: String = "app"
    var sdkAppID: String = ""
    var sdkEphemPubKey: SDKEphemPubKey?
    var sdkReferenceNumber: String = ""
    var sdkTransID: String = ""
    
    public init(sdkEncData: String, sdkAppID: String, sdkEphemPubKey: SDKEphemPubKey?, sdkReferenceNumber: String, sdkTransID: String) {
        self.sdkEncData = sdkEncData
        self.sdkAppID = sdkAppID
        self.sdkEphemPubKey = sdkEphemPubKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransID = sdkTransID
    }
    
    private enum CodingKeys: String, CodingKey {
        case sdkEncData = "sdkEncData"
        case deviceChannel = "deviceChannel"
        case sdkAppID = "sdkAppID"
        case sdkEphemPubKey = "sdkEphemPubKey"
        case sdkReferenceNumber = "sdkReferenceNumber"
        case sdkTransID = "sdkTransID"
    }
}
