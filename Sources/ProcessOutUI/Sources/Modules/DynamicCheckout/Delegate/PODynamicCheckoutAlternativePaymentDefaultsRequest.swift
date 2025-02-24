//
//  PODynamicCheckoutAlternativePaymentDefaultsRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 24.02.2025.
//

import ProcessOut

/// Request to provide default values for alternative payment.
@_spi(PO)
public struct PODynamicCheckoutAlternativePaymentDefaultsRequest {

    /// Gateway configuration ID  that user is paying with.
    public let gatewayConfigurationId: String

    /// Current parameters.
    public let parameters: [PONativeAlternativePaymentMethodParameter]
}
