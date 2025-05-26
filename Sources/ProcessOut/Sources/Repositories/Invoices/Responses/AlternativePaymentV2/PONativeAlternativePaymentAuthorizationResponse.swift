//
//  PONativeAlternativePaymentAuthorizationResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationResponseV2: Sendable, Decodable {

    /// Authorization state.
    public struct State: RawRepresentable, Hashable, Sendable {

        /// The string value representing the type of barcode.
        public let rawValue: String

        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }

    /// Payment state.
    public let state: State

    /// Next step if any.
    public let nextStep: PONativeAlternativePaymentNextStepV2?

    /// Instructions providing additional information to customer and/or describing additional actions.
    public let customerInstructions: [PONativeAlternativePaymentCustomerInstructionV2]?
}

extension PONativeAlternativePaymentAuthorizationResponseV2.State: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

extension PONativeAlternativePaymentAuthorizationResponseV2.State {

    /// Next step is required to proceed.
    public static let nextStepRequired = Self(rawValue: "NEXT_STEP_REQUIRED")

    /// Payment is ready to be captured.
    public static let pendingCapture = Self(rawValue: "PENDING_CAPTURE")

    /// Payment is captured.
    public static let captured = Self(rawValue: "CAPTURED")
}
