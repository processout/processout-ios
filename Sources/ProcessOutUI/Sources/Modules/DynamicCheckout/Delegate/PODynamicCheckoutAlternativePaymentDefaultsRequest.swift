//
//  PODynamicCheckoutAlternativePaymentDefaultsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.02.2025.
//

@_spi(PO) import ProcessOut

/// Request to provide default values for alternative payment.
@_spi(PO)
public struct PODynamicCheckoutAlternativePaymentDefaultsRequest {

    /// Payment method details.
    public let paymentMethod: PODynamicCheckoutPaymentMethod.NativeAlternativePayment

    /// Current parameters.
    public let parameters: [PONativeAlternativePaymentFormV2.Parameter]
}
