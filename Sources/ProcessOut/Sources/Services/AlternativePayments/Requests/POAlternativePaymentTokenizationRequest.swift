//
//  POAlternativePaymentTokenizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 05.08.2024.
//

/// APM tokenization request.
///
/// - NOTE: Make sure to supply proper `additionalData` specific for particular payment
/// method.
public struct POAlternativePaymentTokenizationRequest: Sendable {

    /// Customer ID that may be used for creating APM recurring token.
    public let customerId: String

    /// Customer token ID that may be used for creating APM recurring token.
    public let customerTokenId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// Additional data that will be supplied to the APM.
    public let additionalData: [String: String]?

    /// An object used to evaluate navigation events in a web authentication session.
    public let callback: POWebAuthenticationCallback?

    /// Creates tokenization request.
    public init(
        customerId: String,
        customerTokenId: String,
        gatewayConfigurationId: String,
        additionalData: [String: String]? = nil,
        callback: POWebAuthenticationCallback? = nil
    ) {
        self.customerId = customerId
        self.customerTokenId = customerTokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.additionalData = additionalData
        self.callback = callback
    }
}
