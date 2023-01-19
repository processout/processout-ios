//
//  DirectoryServerData.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 18/06/2019.
//

/// Object passed to the doFingerprint function
public final class DirectoryServerData: Codable {

    public var directoryServerID: String = ""
    public var directoryServerPublicKey: String = ""
    public var threeDSServerTransactionID: String = ""
    public var messageVersion: String = ""
    
    private enum CodingKeys: String, CodingKey {
        case directoryServerID = "directoryServerID"
        case directoryServerPublicKey = "directoryServerPublicKey"
        case threeDSServerTransactionID = "threeDSServerTransID"
        case messageVersion = "messageVersion"
    }
}
