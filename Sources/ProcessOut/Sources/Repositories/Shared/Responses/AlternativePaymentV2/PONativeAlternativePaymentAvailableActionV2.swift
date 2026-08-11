//
//  PONativeAlternativePaymentAvailableActionV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.08.2026.
//

public struct PONativeAlternativePaymentAvailableActionV2: Sendable, Decodable {

    /// The string value representing the type of barcode.
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension PONativeAlternativePaymentAvailableActionV2 {

    /// Authorization is possible.
    public static let authorize = Self(rawValue: "AUTHORIZE")

    /// Capture is possible.
    public static let capture = Self(rawValue: "CAPTURE")
}
