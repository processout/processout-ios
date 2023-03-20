//
//  ThreeDS2AuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.03.2023.
//

import Foundation

struct ThreeDS2AuthenticationRequest: Encodable {

    /// Encrypted device data as a JWE string.
    let deviceData: String?

    /// Device type, defaults to "app".
    let deviceChannel: String = "app"

    /// A unique string identifying the application.
    let sdkAppId: String

    /// The public key component of the ephemeral keypair generated for the transaction, represented as a JWK object.
    let sdkEphemeralPublicKey: [String: String]

    /// A string identifying the SDK, assigned by EMVCo.
    let sdkReferenceNumber: String

    /// A unique string identifying the transaction within the scope of the SDK.
    let sdkTransactionId: String

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case deviceData = "sdkEncData"
        case deviceChannel
        case sdkAppId = "sdkAppID"
        case sdkEphemeralPublicKey = "sdkEphemPubKey"
        case sdkReferenceNumber
        case sdkTransactionId = "sdkTransID"
    }
}
