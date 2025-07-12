//
//  PONativeAlternativePaymentInstructionsGroupV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.06.2025.
//

/// Group of customer instructions.
public struct PONativeAlternativePaymentInstructionsGroupV2: Decodable, Sendable {

    /// Group label if any.
    public let label: String?

    /// Grouped instructions.
    public let instructions: [PONativeAlternativePaymentCustomerInstructionV2]
}
