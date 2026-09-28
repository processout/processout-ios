//
//  PONativeAlternativePaymentFinalizeRequestV2.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 28.09.2026.
//

import ProcessOut

/// Request to finalize native alternative payment.
public struct PONativeAlternativePaymentFinalizeRequestV2: Sendable {

    /// Current payment state. Either ``PONativeAlternativePaymentStateV2/customerActionsCompleted`` or
    /// ``PONativeAlternativePaymentStateV2/authorized`` when payment could still be captured.
    public let paymentState: PONativeAlternativePaymentStateV2

    /// Currently available actions to advance payment.
    public let availableActions: [PONativeAlternativePaymentAvailableActionV2]
}
