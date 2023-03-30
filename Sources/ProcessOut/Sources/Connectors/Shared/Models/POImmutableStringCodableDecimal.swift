//
//  POImmutableStringCodableDecimal.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.11.2022.
//

// swiftlint:disable legacy_objc_type

import Foundation

/// Property wrapper that allows to encode and decode `Decimal` to/from string representation. Value is coded
/// in en_US locale.
@propertyWrapper
public struct POImmutableStringCodableDecimal: Codable {

    public let wrappedValue: Decimal

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

extension KeyedEncodingContainer {

    mutating func encode(
        _ value: POImmutableStringCodableDecimal, forKey key: KeyedEncodingContainer<K>.Key
    ) throws {
        try value.encode(to: superEncoder(forKey: key))
    }
}

extension KeyedDecodingContainer {

    func decode(
        _ type: POImmutableStringCodableDecimal.Type, forKey key: KeyedDecodingContainer<K>.Key
    ) throws -> POImmutableStringCodableDecimal {
        try type.init(from: try superDecoder(forKey: key))
    }
}
