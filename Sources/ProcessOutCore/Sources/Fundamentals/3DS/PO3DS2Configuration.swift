//
//  PO3DS2Configuration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 02.11.2022.
//

/// Represents the configuration parameters that are required by the 3DS SDK for initialization.
@available(iOS 15, *)
@_originallyDefinedIn(module: "ProcessOut", iOS 15)
public struct PO3DS2Configuration: Codable, Hashable, Sendable {

    /// The identifier of the directory server to use during the transaction creation phase.
    public let directoryServerId: String

    /// The public key of the directory server to use during the transaction creation phase.
    public let directoryServerPublicKey: String

    /// An array of DER-encoded x509 certificate strings containing the DS root certificate used for signature checks.
    public let directoryServerRootCertificates: [String]

    /// Unique identifier for the authentication assigned by the DS (Card Scheme).
    public let directoryServerTransactionId: String

    /// Card scheme from the card used to initiate the payment.
    @POTypedRepresentation<PO3DS2ConfigurationCardScheme?, POCardScheme>
    public private(set) var scheme: PO3DS2ConfigurationCardScheme?

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

extension KeyedDecodingContainer {

    public func decode(
        _ type: POTypedRepresentation<PO3DS2ConfigurationCardScheme?, POCardScheme>.Type,
        forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POTypedRepresentation<PO3DS2ConfigurationCardScheme?, POCardScheme> {
        let wrapper = try decodeIfPresent(
            POTypedRepresentation<PO3DS2ConfigurationCardScheme?, POCardScheme>.self,
            forKey: key
        )
        return wrapper ?? .init(wrappedValue: nil)
    }
}

extension KeyedEncodingContainer {

    public mutating func encode(
        _ value: POTypedRepresentation<PO3DS2ConfigurationCardScheme?, POCardScheme>,
        forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        let wrapper = value.typed().map { _ in value }
        try encodeIfPresent(wrapper, forKey: key)
    }
}
