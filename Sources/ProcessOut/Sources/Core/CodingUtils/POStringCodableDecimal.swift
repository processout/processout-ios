//
//  POStringCodableDecimal.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.11.2022.
//

// swiftlint:disable legacy_objc_type

import Foundation

/// Property wrapper that allows to encode and decode `Decimal` to/from string representation. Value is coded
/// in en_US locale.
@propertyWrapper
public struct POStringCodableDecimal: Codable, Sendable {

    public var wrappedValue: Decimal

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        wrappedValue = NSDecimalNumber(string: value, locale: Self.locale).decimalValue
        guard description != value else {
            return
        }
        let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid decimal value.")
        throw DecodingError.dataCorrupted(context)
    }

    public init(value: Decimal) {
        self.wrappedValue = value
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(description)
    }

    // MARK: - Private Properties

    private static let locale = NSLocale(localeIdentifier: "en_US")

    private var description: String {
        NSDecimalNumber(decimal: wrappedValue).description(withLocale: Self.locale)
    }
}

// swiftlint:enable legacy_objc_type

extension KeyedEncodingContainer {

    public mutating func encode(
        _ value: POStringCodableDecimal, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        try value.encode(to: superEncoder(forKey: key))
    }
}

extension KeyedDecodingContainer {

    public func decode(
        _ type: POStringCodableDecimal.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POStringCodableDecimal {
        try type.init(from: try superDecoder(forKey: key))
    }
}
