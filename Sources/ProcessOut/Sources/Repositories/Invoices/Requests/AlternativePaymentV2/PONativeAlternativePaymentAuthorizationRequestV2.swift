//
//  PONativeAlternativePaymentAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationRequestV2: Sendable, Encodable {

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    /// Payment source.
    public let source: String?

    /// Payment request parameters.
    public let submitData: PONativeAlternativePaymentSubmitDataV2?

    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        source: String? = nil,
        submitData: PONativeAlternativePaymentSubmitDataV2?
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.source = source
        self.submitData = submitData
    }
}
