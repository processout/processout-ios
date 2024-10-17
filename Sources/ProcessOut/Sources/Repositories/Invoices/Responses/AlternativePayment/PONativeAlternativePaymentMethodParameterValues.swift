//
//  PONativeAlternativePaymentMethodParameterValues.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.06.2023.
//

import Foundation

/// Native alternative payment parameter values.
public struct PONativeAlternativePaymentMethodParameterValues: Decodable, Sendable {

    /// Represents the type of barcode (e.g., QR code, UPC, etc.).
    public struct BarcodeType: RawRepresentable, Sendable, Hashable {

        /// The string value representing the type of barcode.
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// Represents a barcode with its type and encoded data.
    public struct Barcode: Decodable, Sendable {

        /// The type of the barcode.
        public let type: BarcodeType

        /// The data encoded within the barcode.
        public let value: Data
    }

    /// Message.
    public let message: String?

    /// Customer action message markdown that should be used to explain user how to proceed with payment. Currently
    /// it will be set only when payment state is `PENDING_CAPTURE`.
    public let customerActionMessage: String?

    /// A barcode that represents the customer's action, such as a QR code for payment.
    public let customerActionBarcode: Barcode?

    /// Payment provider name.
    public let providerName: String?

    /// Payment provider logo URL if available.
    public let providerLogoUrl: URL?
}

extension PONativeAlternativePaymentMethodParameterValues.BarcodeType: Decodable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }
}

extension PONativeAlternativePaymentMethodParameterValues.BarcodeType {

    /// Represents a QR (Quick Response) code type.
    public static let qr = Self(rawValue: "QR") // swiftlint:disable:this identifier_name
}
