//
//  POFallbackDecodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2023.
//

import Foundation

/// Allows decoding to fallback to default when value is not present.
@propertyWrapper
public struct POFallbackDecodable<Provider: POFallbackValueProvider>: Codable where Provider.Value: Codable {

    public var wrappedValue: Provider.Value

    public init(wrappedValue: Provider.Value) {
        self.wrappedValue = wrappedValue
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self.wrappedValue = Provider.defaultValue
        } else {
            self.wrappedValue = try container.decode(Provider.Value.self)
        }
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {

    public func decode<P>(
        _ type: POFallbackDecodable<P>.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POFallbackDecodable<P> {
        let wrapper = try decodeIfPresent(POFallbackDecodable<P>.self, forKey: key)
        return wrapper ?? .init(wrappedValue: P.defaultValue)
    }
}

// MARK: - Hashable

extension POFallbackDecodable: Hashable, Equatable where Provider.Value: Hashable { }

// MARK: - Sendable

extension POFallbackDecodable: Sendable where Provider.Value: Sendable { }
