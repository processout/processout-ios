//
//  PO3DS2ChallengeParameters.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

@available(*, deprecated, renamed: "PO3DS2ChallengeParameters")
public typealias PO3DS2Challenge = PO3DS2ChallengeParameters

/// Information from the 3DS Server's authentication response that could be used by the 3DS2 SDK to initiate
/// the challenge flow.
public struct PO3DS2ChallengeParameters: Codable, Hashable, Sendable {

    /// Unique transaction identifier assigned by the ACS.
    public let acsTransactionId: String

    /// Unique identifier that identifies the ACS service provider.
    public let acsReferenceNumber: String

    /// The encrypted message containing the ACS information (including Ephemeral Public Key) and
    /// the 3DS2 SDK ephemeral public key.
    public let acsSignedContent: String

    /// Unique identifier for the authentication assigned by the DS (Card Scheme).
    public let threeDSServerTransactionId: String

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case acsTransactionId = "acsTransID"
        case acsReferenceNumber
        case acsSignedContent
        case threeDSServerTransactionId = "threeDSServerTransID"
    }
}
