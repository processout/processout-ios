//
//  POImmutableExcludedCodable.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.10.2022.
//

import Foundation

/// Property wrapper that allows to exclude property from being encoded without forcing owning parent to define
/// custom `CodingKeys`.
///
/// - NOTE: Wrapped value is immutable.
@propertyWrapper
@available(*, deprecated, message: "No longer in use.")
public struct POImmutableExcludedCodable<Value>: Encodable {

    public let wrappedValue: Value

    /// Creates property wrapper instance.
    public init(value: Value) {
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws { }
}

extension KeyedEncodingContainer {

    @available(*, deprecated, message: "No longer in use.")
    public mutating func encode<T>(
        _ value: POImmutableExcludedCodable<T>, forKey key: KeyedEncodingContainer<K>.Key
    ) throws { /* Ignored */ }
}
