//
//  POAuthentificationChallengeData.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

@_spi(PO)
public struct POAuthentificationChallengeData: Decodable {

    /// Unique transaction identifier assigned by the ACS.
    public let acsTransactionId: String

    /// Unique identifier that identifies the ACS service provider.
    public let acsReferenceNumber: String

    /// JWS object (represented as a string) containing, among other data, the ACS Ephemeral Public Key.
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
