//
//  POAuthorizationResult.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

import Foundation

public enum POCustomerAction {

    /// Device fingerprint is required.
    case fingerprintMobile(directoryServerData: Data)

    /// Customer is required to complete challenge to continue.
    case challengeMobile(authentificationChallengeData: Data)

    /// Customer must be redirected to given URL to continue.
    case url(URL), redirect(URL)

    /// Device fingerprint is required.
    case fingerprint(URL)
}

extension POCustomerAction: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(RawCustomerActionType.self, forKey: .type) {
        case .fingerprintMobile:
            let data = try container.decode(Data.self, forKey: .value)
            self = .fingerprintMobile(directoryServerData: data)
        case .challengeMobile:
            let data = try container.decode(Data.self, forKey: .value)
            self = .challengeMobile(authentificationChallengeData: data)
        case .url:
            let url = try container.decode(URL.self, forKey: .value)
            self = .url(url)
        case .redirect:
            let url = try container.decode(URL.self, forKey: .value)
            self = .redirect(url)
        case .fingerprint:
            let url = try container.decode(URL.self, forKey: .value)
            self = .fingerprint(url)
        }
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case value, type
    }

    public enum RawCustomerActionType: String, Decodable {
        case fingerprintMobile = "fingerprint-mobile", challengeMobile = "challenge-mobile", url, redirect, fingerprint
    }
}
