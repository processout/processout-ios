//
//  POPhoneNumberMetadata.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 16.03.2023.
//

@_spi(PO)
public struct POPhoneNumberMetadata: Decodable, Sendable {

    public struct Format: Decodable, Sendable {

        /// Formatting patern.
        public let pattern: String

        /// Leading digits pattern.
        public let leading: [String]

        /// Format to use for number.
        public let format: String
    }

    /// ISO 3166-1 alpha-2 country code.
    public let id: String

    /// E.164 Country Code.
    public let countryCode: String

    /// Available formats.
    public let formats: [Format]
}
