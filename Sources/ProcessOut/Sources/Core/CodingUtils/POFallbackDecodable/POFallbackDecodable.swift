//
//  POFallbackDecodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.11.2023.
//

import Foundation

/// Allows decoding to fallback to default when value is not present.
@propertyWrapper
public struct POFallbackDecodable<Provider: POFallbackValueProvider>: Decodable where Provider.Value: Decodable {

    public var wrappedValue: Provider.Value

    public init(wrappedValue: Provider.Value) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {

    public func decode<P>(
        _ type: POFallbackDecodable<P>.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POFallbackDecodable<P> {
        POFallbackDecodable(wrappedValue: try decodeIfPresent(P.Value.self, forKey: key) ?? P.defaultValue)
    }
}

extension POFallbackDecodable: Hashable, Equatable where Provider.Value: Hashable { }

extension POFallbackDecodable: Sendable where Provider.Value: Sendable { }
