//
//  POAlternativePaymentMethodRequest.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

import Foundation

@_spi(PO)
public struct POAlternativePaymentMethodRequest {

    /// Invoice identifier to to perform apm payment for.
    public let invoiceId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// Additional Data that will be supplied to the APM.
    public let additionalData: [String: String]?

    /// Customer  ID that may be used for creating APM recurring token.
    public let customerId: String?

    /// Customer token ID that may be used for creating APM recurring token.
    public let tokenId: String?

    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        additionalData: [String: String]? = nil,
        customerId: String? = nil,
        tokenId: String? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.additionalData = additionalData
        self.customerId = customerId
        self.tokenId = tokenId
    }
}
