//
//  POTyped.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2024.
//

import Foundation

/// Introduces typed version of a property in a backward compatible way.
@propertyWrapper
public struct POTyped<Wrapped, Representation: RawRepresentable> {

    public init(wrappedValue: Wrapped) {
        self.wrappedValue = wrappedValue
    }

    public var wrappedValue: Wrapped

    public var projectedValue: Self {
        self
    }

    /// Returns typed representation of self.
    public func typed() -> Representation where Representation.RawValue == Wrapped {
        Representation(rawValue: wrappedValue)! // swiftlint:disable:this force_unwrapping
    }

    /// Returns typed representation of self.
    public func typed<T>() -> Representation? where Wrapped == T?, Representation.RawValue == T {
        wrappedValue.flatMap { Representation(rawValue: $0) }
    }
}

extension POTyped: Hashable where Wrapped: Hashable {

    public func hash(into hasher: inout Hasher) {
        wrappedValue.hash(into: &hasher)
    }
}

extension POTyped: Equatable where Wrapped: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension POTyped: Encodable where Wrapped: Encodable {

    public func encode(to encoder: any Encoder) throws {
        try wrappedValue.encode(to: encoder)
    }
}

extension POTyped: Decodable where Wrapped: Decodable {

    public init(from decoder: any Decoder) throws {
        let wrappedValue = try Wrapped(from: decoder)
        self = .init(wrappedValue: wrappedValue)
    }
}

extension KeyedEncodingContainer {

    public mutating func encode<Wrapped: Encodable, Representation: RawRepresentable>(
        _ value: POTyped<Wrapped, Representation>, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        try value.encode(to: superEncoder(forKey: key))
    }
}

extension KeyedDecodingContainer {

    public func decode<Wrapped: Decodable, Representation: RawRepresentable>(
        _ type: POTyped<Wrapped, Representation>.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POTyped<Wrapped, Representation> {
        try type.init(from: try superDecoder(forKey: key))
    }
}
