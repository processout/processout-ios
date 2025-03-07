//
//  POImmutableExcludedCodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

@available(*, deprecated, renamed: "POExcludedEncodable")
public typealias POImmutableExcludedCodable = POExcludedEncodable

/// Property wrapper that allows to exclude property from being encoded without forcing owning parent to define
/// custom `CodingKeys`.
///
/// - NOTE: Wrapped value is immutable.
@propertyWrapper
public struct POExcludedEncodable<Value: Codable>: Codable {

    public var wrappedValue: Value

    /// Creates property wrapper instance.
    public init(wrappedValue: Value) {
        self.wrappedValue = wrappedValue
    }

    @available(*, deprecated)
    public init(value: Value) {
        self.wrappedValue = value
    }

    // MARK: - Codable

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }

    public func encode(to encoder: Encoder) throws {
        // Ignored
    }
}

extension KeyedEncodingContainer {

    public mutating func encode<T>(
        _ value: POExcludedEncodable<T>, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        // Ignored
    }
}

extension KeyedDecodingContainer {

    public func decode<T>(
        _ type: POExcludedEncodable<T?>.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POExcludedEncodable<T?> {
        let wrapper = try decodeIfPresent(POExcludedEncodable<T?>.self, forKey: key)
        return wrapper ?? .init(wrappedValue: nil)
    }
}

// MARK: - Sendable

extension POExcludedEncodable: Sendable where Value: Sendable { }
