//
//  PO3DS2AuthenticationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

/// Holds transaction data that the 3DS Server requires to create the AReq.
public struct PO3DS2AuthenticationRequest: Hashable, Sendable {

    /// Encrypted device data as a JWE string.
    public let deviceData: String

    /// A unique string identifying the application.
    public let sdkAppId: String

    /// The public key component of the ephemeral keypair generated for the transaction, represented as a JWK string.
    public let sdkEphemeralPublicKey: String

    /// A string identifying the SDK, assigned by EMVCo.
    public let sdkReferenceNumber: String

    /// A unique string identifying the transaction within the scope of the SDK.
    public let sdkTransactionId: String

    public init(
        deviceData: String,
        sdkAppId: String,
        sdkEphemeralPublicKey: String,
        sdkReferenceNumber: String,
        sdkTransactionId: String
    ) {
        self.deviceData = deviceData
        self.sdkAppId = sdkAppId
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransactionId = sdkTransactionId
    }
}
