//
//  AuthorizationRequest.swift
//  ProcessOut
//
//  Created by Jeremy Lejoux on 17/06/2019.
//

public final class AuthorizationRequest: Codable {

    var invoiceID: String = ""
    var source: String = ""
    var incremental: Bool = false
    var threeDS2Enabled: Bool = true

    public var thirdPartySDKVersion: String = ""
    public var preferredScheme: String = ""

    public init(source: String, incremental: Bool, invoiceID: String) {
        self.source = source
        self.incremental = incremental
        self.invoiceID = invoiceID
    }

    private enum CodingKeys: String, CodingKey {
        case invoiceID = "invoice_id"
        case source = "source"
        case thirdPartySDKVersion = "third_party_sdk_version"
        case incremental = "incremental"
        case threeDS2Enabled = "enable_three_d_s_2"
        case preferredScheme = "preferred_scheme"
    }
}
