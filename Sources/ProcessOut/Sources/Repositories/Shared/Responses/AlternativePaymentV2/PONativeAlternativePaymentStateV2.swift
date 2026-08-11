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

    /// Customer interaction completed. Explicit authorize and/or capture is expected to advance payment.
    public static let customerActionsCompleted = Self(rawValue: "CUSTOMER_ACTIONS_COMPLETED")

    /// Authorization was requested and it’s still pending. No further actions are expected, payment will
    /// advance to next state automatically.
    public static let authorizationPending = Self(rawValue: "AUTHORIZATION_PENDING")

    /// Authorization was requested and completed.
    public static let authorized = Self(rawValue: "AUTHORIZED")

    /// Payment is successfully completed.
    public static let success = Self(rawValue: "SUCCESS")
}
