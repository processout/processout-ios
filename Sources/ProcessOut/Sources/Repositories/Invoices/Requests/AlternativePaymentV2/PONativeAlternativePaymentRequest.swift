//
//  PONativeAlternativePaymentRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 15.05.2025.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentRequest: Sendable {

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    public init(invoiceId: String, gatewayConfigurationId: String) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
    }
}
