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

    /// Currently available actions to advance payment.
    public let availableActions: [PONativeAlternativePaymentAvailableActionV2]
}
