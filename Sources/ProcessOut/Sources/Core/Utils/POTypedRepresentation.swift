//
//  POTypedRepresentation.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.06.2024.
//

// todo(andrii-vysotskyi): remove when updating to 5.0.0

import Foundation

/// Introduces typed version of a property in a backward compatible way.
@propertyWrapper
public struct POTypedRepresentation<Wrapped, Representation: RawRepresentable> {

    public init(wrappedValue: Wrapped) {
        self._wrappedValue = wrappedValue
    }

    @available(*, deprecated, message: "Use typed representation accessible via projectedValue.typed instead.")
    public var wrappedValue: Wrapped {
        get { _wrappedValue }
        set { _wrappedValue = newValue }
    }

    public var projectedValue: Self {
        self
    }

    // MARK: - Private Properties

    private var _wrappedValue: Wrapped
}

extension POTypedRepresentation where Representation.RawValue == Wrapped {

    /// Returns typed representation of self.
    public var typed: Representation {
        Representation(rawValue: _wrappedValue)! // swiftlint:disable:this force_unwrapping
    }
}

extension POTypedRepresentation where Representation.RawValue? == Wrapped {

    /// Returns typed representation of self.
    public var typed: Representation? {
        _wrappedValue.flatMap { Representation(rawValue: $0) }
    }
}

extension POTypedRepresentation {

    /// Returns typed representation of self.
    public func typed<T>(wrappedType: T.Type = T.self) -> Representation? where Wrapped == T?, T: RawRepresentable, T.RawValue == Representation.RawValue { // swiftlint:disable:this line_length
        _wrappedValue.flatMap { Representation(rawValue: $0.rawValue) }
    }
}

extension POTypedRepresentation: Hashable where Wrapped: Hashable {

    public func hash(into hasher: inout Hasher) {
        _wrappedValue.hash(into: &hasher)
    }
}

extension POTypedRepresentation: Equatable where Wrapped: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs._wrappedValue == rhs._wrappedValue
    }
}

extension POTypedRepresentation: Encodable where Wrapped: Encodable {

    public func encode(to encoder: any Encoder) throws {
        try _wrappedValue.encode(to: encoder)
    }
}

extension POTypedRepresentation: Decodable where Wrapped: Decodable {

    public init(from decoder: any Decoder) throws {
        let wrappedValue = try Wrapped(from: decoder)
        self = .init(wrappedValue: wrappedValue)
    }
}

extension KeyedEncodingContainer {

    public mutating func encode<Wrapped: Encodable, Representation: RawRepresentable>(
        _ value: POTypedRepresentation<Wrapped, Representation>, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        try value.encode(to: superEncoder(forKey: key))
    }
}

extension KeyedDecodingContainer {

    public func decode<Wrapped: Decodable, Representation: RawRepresentable>(
        _ type: POTypedRepresentation<Wrapped, Representation>.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POTypedRepresentation<Wrapped, Representation> {
        try type.init(from: try superDecoder(forKey: key))
    }
}
