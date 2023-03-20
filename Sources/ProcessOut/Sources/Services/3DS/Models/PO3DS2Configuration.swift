//
//  PO3DS2Configuration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

/// Represent the configuration parameters that are required by the 3DS SDK for initialization.
@_spi(PO)
public struct PO3DS2Configuration: Decodable {

    /// The identifier of the directory server to use during the transaction creation phase.
    public let directoryServerId: String

    /// The public key of the directory server to use during the transaction creation phase.
    public let directoryServerPublicKey: String

    /// Unique identifier for the authentication assigned by the DS (Card Scheme).
    public let directoryServerTransactionId: String

    /// 3DS protocol version identifier.
    public let messageVersion: String

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case directoryServerId = "directoryServerID"
        case directoryServerPublicKey = "directoryServerPublicKey"
        case directoryServerTransactionId = "threeDSServerTransID"
        case messageVersion
    }
}
