//
//  POImmutableStringCodableOptionalDecimal.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.10.2022.
//

// swiftlint:disable legacy_objc_type

import Foundation

@propertyWrapper
public struct POImmutableStringCodableOptionalDecimal: Codable {

    public let wrappedValue: Decimal?

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
        wrappedValue.map(NSDecimalNumber.init)?.description(withLocale: Self.locale)
    }
}
