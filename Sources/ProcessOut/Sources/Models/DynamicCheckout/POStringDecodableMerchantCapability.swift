//
//  POStringDecodableMerchantCapability.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.05.2024.
//

import PassKit

/// Property wrapper allowing to decode `PKMerchantCapability`.
@propertyWrapper
public struct POStringDecodableMerchantCapability: Codable, Sendable {

    public let wrappedValue: PKMerchantCapability

    // MARK: - Decodable

    public init(from decoder: any Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        var capabilities: PKMerchantCapability = []
        while !unkeyedContainer.isAtEnd {
            switch try? unkeyedContainer.decode(MerchantCapability.self) {
            case .credit:
                capabilities.insert(.credit)
            case .debit:
                capabilities.insert(.debit)
            case .threeDS:
                capabilities.insert(.threeDSecure)
            case .emv:
                capabilities.insert(.emv)
            case nil:
                continue
            }
        }
        self.wrappedValue = capabilities
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.unkeyedContainer()
        let capabilities: [MerchantCapability: PKMerchantCapability] = [
            .credit: .credit, .debit: .debit, .threeDS: .threeDSecure, .emv: .emv
        ]
        let includedCapabilities = capabilities
            .filter { wrappedValue.contains($0.value) }
            .compactMap(\.key)
        try container.encode(contentsOf: includedCapabilities)
    }

    // MARK: - Private Nested Types

    private enum MerchantCapability: String, Codable {
        case threeDS = "supports3DS", credit = "supportsCredit", debit = "supportsDebit", emv = "supportsEMV"
    }
}
