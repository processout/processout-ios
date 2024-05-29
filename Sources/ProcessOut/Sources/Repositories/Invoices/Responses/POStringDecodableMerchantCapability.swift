//
//  POStringDecodableMerchantCapability.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.05.2024.
//

import PassKit

/// Property wrapper allowing to decode `PKMerchantCapability`.
@propertyWrapper
public struct POStringDecodableMerchantCapability: Decodable {

    public let wrappedValue: PKMerchantCapability

    // MARK: - Decodable

    public init(from decoder: any Decoder) throws {
        var unkeyedContainer = try decoder.unkeyedContainer()
        var capabilities: PKMerchantCapability = []
        while !unkeyedContainer.isAtEnd {
            // todo(andrii-vysotskyi): decide if instantFundsOut and emv should be supported
            switch try? unkeyedContainer.decode(MerchantCapability.self) {
            case .credit:
                capabilities.insert(.credit)
            case .debit:
                capabilities.insert(.debit)
            case .threeDS:
                capabilities.insert(.threeDSecure)
            case nil:
                capabilities = []
            }
        }
        self.wrappedValue = capabilities
    }

    // MARK: - Private

    private enum MerchantCapability: String, Decodable {
        case threeDS = "supports3DS", credit = "supportsCredit", debit = "supportsDebit"
    }
}

extension KeyedDecodingContainer {

    public func decode(
        _ type: POStringDecodableMerchantCapability.Type, forKey key: K
    ) throws -> POStringDecodableMerchantCapability {
        try type.init(from: try superDecoder(forKey: key))
    }
}
