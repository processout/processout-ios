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
    public let tokenId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// Additional data that will be supplied to the APM.
    public let additionalData: [String: String]?

    /// Creates tokenization request.
    public init(
        customerId: String,
        tokenId: String,
        gatewayConfigurationId: String,
        additionalData: [String: String]? = nil
    ) {
        self.customerId = customerId
        self.tokenId = tokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.additionalData = additionalData
    }
}
