//
//  POBarcode.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2024.
//

import Foundation

/// Represents a barcode with its type and encoded data.
public struct POBarcode: Decodable, Sendable {

    /// Represents the type of barcode (e.g., QR code, UPC, etc.).
    public struct BarcodeType: RawRepresentable, Sendable, Hashable {

        /// The string value representing the type of barcode.
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// The type of the barcode.
    public let type: BarcodeType

    /// The value to encode in the barcode.
    public let value: Data
}

extension POBarcode.BarcodeType: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

extension POBarcode.BarcodeType {

    /// Represents a QR (Quick Response) code type.
    public static let qr = Self(rawValue: "qr") // swiftlint:disable:this identifier_name
}
