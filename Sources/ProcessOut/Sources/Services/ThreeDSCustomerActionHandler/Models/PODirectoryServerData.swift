//
//  PODirectoryServerData.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

@_spi(PO)
public struct PODirectoryServerData: Decodable {

    /// The identifier of the directory server to use during the transaction creation phase.
    public let id: String

    /// The public key of the directory server to use during the transaction creation phase.
    public let publicKey: String

    /// Unique identifier for the authentication assigned by the DS (Card Scheme).
    public let transactionId: String

    /// 3DS protocol version identifier.
    public let messageVersion: String

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case id = "directoryServerID"
        case publicKey = "directoryServerPublicKey"
        case transactionId = "threeDSServerTransID"
        case messageVersion
    }
}
