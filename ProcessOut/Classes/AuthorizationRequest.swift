//
//  AuthorizationRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

public class AuthorizationRequest: Codable {
    var invoiceID: String = ""
    var source: String = ""
    public var thirdPartySDKVersion: String = ""
    var incremental: Bool = false
    var threeDS2Enabled: Bool = true
    public var preferredScheme: String = ""

    enum CodingKeys: String, CodingKey {
        case invoiceID = "invoice_id"
        case source = "source"
        case thirdPartySDKVersion = "third_party_sdk_version"
        case incremental = "incremental"
        case threeDS2Enabled = "enable_three_d_s_2"
        case preferredScheme = "preferred_scheme"
    }
    
    public init(source: String, incremental: Bool, invoiceID: String) {
        self.source = source
        self.incremental = incremental
        self.invoiceID = invoiceID
    }

}
