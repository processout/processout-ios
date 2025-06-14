//
//  PONativeAlternativePaymentTokenizationResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentTokenizationResponseV2: Sendable, Decodable {

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Next step if any.
    public let nextStep: PONativeAlternativePaymentNextStepV2?

    /// Instructions providing additional information to customer and/or describing additional actions.
    public let customerInstructions: [PONativeAlternativePaymentCustomerInstructionV2]?
}
