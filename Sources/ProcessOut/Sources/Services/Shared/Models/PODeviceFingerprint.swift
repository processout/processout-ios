//
//  PODeviceFingerprint.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 03.11.2022.
//

public struct PODeviceFingerprint: Encodable {

    public struct EphemeralPublicKey: Codable {

        /// The crv member identifies the cryptographic curve used with the key. Values defined by this specification
        /// are P-256, P-384 and P-521. Additional crv values MAY be used, provided they are understood by
        /// implementations using that Elliptic Curve key. The crv value is case sensitive.
        public let crv: String

        /// The "kty" (key type) parameter identifies the cryptographic algorithm family used with the key,
        /// such as "RSA" or "EC".
        public let kty: String

        /// The x member contains the x coordinate for the elliptic curve point. It is represented as the base64url
        /// encoding of the coordinate's big endian representation.
        public let x: String // swiftlint:disable:this identifier_name

        /// The y member contains the y coordinate for the elliptic curve point. It is represented as the base64url
        /// encoding of the coordinate's big endian representation.
        public let y: String // swiftlint:disable:this identifier_name
    }

    /// The device information, encrypted using JSON Web Encryption.
    public let deviceInformation: String

    /// Device type, defaults to "app".
    public let deviceChannel: String

    /// A unique string identifying the application.
    public let applicationId: String

    /// The public key component of the ephemeral keypair generated for the transaction, represented as a JWK.
    public let sdkEphemeralPublicKey: EphemeralPublicKey?

    /// A string identifying the SDK, assigned by EMVCo.
    public let sdkReferenceNumber: String

    /// A unique string identifying the transaction within the scope of the SDK.
    public let sdkTransactionId: String

    public init(
        deviceInformation: String,
        applicationId: String,
        sdkEphemeralPublicKey: EphemeralPublicKey?,
        sdkReferenceNumber: String,
        sdkTransactionId: String
    ) {
        self.deviceInformation = deviceInformation
        self.deviceChannel = "app"
        self.applicationId = applicationId
        self.sdkEphemeralPublicKey = sdkEphemeralPublicKey
        self.sdkReferenceNumber = sdkReferenceNumber
        self.sdkTransactionId = sdkTransactionId
    }

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case deviceInformation = "sdkEncData"
        case deviceChannel
        case applicationId = "sdkAppID"
        case sdkEphemeralPublicKey = "sdkEphemPubKey"
        case sdkReferenceNumber
        case sdkTransactionId = "sdkTransID"
    }
}
