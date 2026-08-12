//
//  PONativeAlternativePaymentAvailableActionV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.08.2026.
//

public struct PONativeAlternativePaymentAvailableActionV2: Sendable {

    /// The string value representing the type of barcode.
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension PONativeAlternativePaymentAvailableActionV2: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension PONativeAlternativePaymentAvailableActionV2 {

    /// Authorization is possible.
    public static let authorize = Self(rawValue: "AUTHORIZE")

    /// Capture is possible.
    public static let capture = Self(rawValue: "CAPTURE")
}
