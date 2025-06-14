//
//  PONativeAlternativePaymentState.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.06.2025.
//

/// Payment state.
public struct PONativeAlternativePaymentStateV2: RawRepresentable, Hashable, Sendable {

    /// The string value representing the type of barcode.
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

extension PONativeAlternativePaymentStateV2: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension PONativeAlternativePaymentStateV2 {

    /// Next step is required to proceed.
    public static let nextStepRequired = Self(rawValue: "NEXT_STEP_REQUIRED")

    /// Payment is pending.
    public static let pending = Self(rawValue: "PENDING")

    /// Payment is completed.
    public static let completed = Self(rawValue: "COMPLETED")
}
