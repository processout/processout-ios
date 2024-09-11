//
//  POStringCodableOptionalDecimal.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

// swiftlint:disable legacy_objc_type

import Foundation

/// Property wrapper that allows to encode and decode optional `Decimal` to/from string representation. Value is coded
/// in en_US locale.
@propertyWrapper
public struct POStringCodableOptionalDecimal: Codable, Sendable {

    public var wrappedValue: Decimal?

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(Optional<String>.self)
        if let value {
            wrappedValue = NSDecimalNumber(string: value, locale: Self.locale).decimalValue
        } else {
            wrappedValue = nil
        }
        guard description != value else {
            return
        }
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid decimal value.")
        throw DecodingError.dataCorrupted(context)
    }

    public init(value: Decimal?) {
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    // MARK: - Private Properties

    private static let locale = NSLocale(localeIdentifier: "en_US")

    private var description: String? {
        wrappedValue.map { NSDecimalNumber(decimal: $0) }?.description(withLocale: Self.locale)
    }
}

// swiftlint:enable legacy_objc_type

extension KeyedEncodingContainer {

    public mutating func encode(
        _ value: POStringCodableOptionalDecimal, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        try value.encode(to: superEncoder(forKey: key))
    }
}

extension KeyedDecodingContainer {

    public func decode(
        _ type: POStringCodableOptionalDecimal.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POStringCodableOptionalDecimal {
        try type.init(from: try superDecoder(forKey: key))
    }
}
