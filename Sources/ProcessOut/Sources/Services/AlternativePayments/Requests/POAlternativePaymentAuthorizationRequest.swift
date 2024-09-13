//
//  POAlternativePaymentAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.08.2024.
//

/// Invoice authorization request.
///
/// - NOTE: Make sure to supply proper `additionalData` specific for particular payment
/// method.
public struct POAlternativePaymentAuthorizationRequest: Sendable {

    /// Invoice identifier to to perform APM payment for.
    public let invoiceId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// When value is set invoice is being authorized with previously tokenized APM.
    public let customerTokenId: String?

    /// Additional Data that will be supplied to the APM.
    public let additionalData: [String: String]?

    /// Creates authorization request.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        customerTokenId: String? = nil,
        additionalData: [String: String]? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.customerTokenId = customerTokenId
        self.additionalData = additionalData
    }
}
