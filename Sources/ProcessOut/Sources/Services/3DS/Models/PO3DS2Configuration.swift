//
//  PO3DS2Configuration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

/// Represents the configuration parameters that are required by the 3DS SDK for initialization.
public struct PO3DS2Configuration: Decodable {

    /// The identifier of the directory server to use during the transaction creation phase.
    public let directoryServerId: String

    /// The public key of the directory server to use during the transaction creation phase.
    public let directoryServerPublicKey: String

    /// An array of DER-encoded x509 certificate strings containing the DS root certificate used for signature checks.
    public let directoryServerRootCertificates: [String]

    /// Unique identifier for the authentication assigned by the DS (Card Scheme).
    public let directoryServerTransactionId: String

    /// Card scheme from the card used to initiate the payment.
    public let scheme: PO3DS2ConfigurationCardScheme?

    /// 3DS protocol version identifier.
    public let messageVersion: String

    // MARK: - Private Nested Types

    private enum CodingKeys: String, CodingKey {
        case directoryServerId = "directoryServerID"
        case directoryServerPublicKey
        case directoryServerRootCertificates = "directoryServerRootCAs"
        case directoryServerTransactionId = "threeDSServerTransID"
        case scheme
        case messageVersion
    }
}
