//
//  PODynamicCheckoutAlternativePaymentFinalizeRequest.swift
//  ProcessOutUI
//
//  Created by Andrii Vysotskyi on 22.09.2026.
//

@_spi(PO) import ProcessOut

/// Request to finalize alternative payment.
@_spi(PO)
public struct PODynamicCheckoutAlternativePaymentFinalizeRequest {

    /// Payment method details.
    public let paymentMethod: PODynamicCheckoutPaymentMethod.NativeAlternativePayment

    /// Current payment state. Either ``PONativeAlternativePaymentStateV2/customerActionsCompleted`` or
    /// ``PONativeAlternativePaymentStateV2/authorized`` when payment could still be captured.
    public let paymentState: PONativeAlternativePaymentStateV2

    /// Currently available actions to advance payment.
    public let availableActions: [PONativeAlternativePaymentAvailableActionV2]
}
