//
//  POAlternativePaymentMethodRequest.swift
//  ProcessOut
//
//  Created by Simeon Kostadinov on 27/10/2022.
//

// todo(andrii-vysotskyi): consider splitting request into separate tokenization and authorization requests

import Foundation

/// Request describing parameters that are used to create URL that user can be redirected to initiate
/// alternative payment.
///
/// - NOTE: Make sure to supply proper `additionalData` specific for particular payment
/// method.
@available(*, deprecated, message: "Use POAlternativePaymentAuthorizationRequest or POAlternativePaymentTokenizationRequest instead.") // swiftlint:disable:this line_length
public struct POAlternativePaymentMethodRequest {

    /// Invoice identifier to to perform APM payment for.
    public let invoiceId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// Customer  ID that may be used for creating APM recurring token.
    public let customerId: String?

    /// Customer token ID that may be used for creating APM recurring token.
    public let tokenId: String?

    /// Additional Data that will be supplied to the APM.
    public let additionalData: [String: String]?

    @_disfavoredOverload
    @available(*, deprecated, message: "Use other init that creates either tokenization or payment request explicitly.")
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

    /// Creates a request that can be used to tokenize APM.
    public init(
        customerId: String,
        tokenId: String,
        gatewayConfigurationId: String,
        additionalData: [String: String]? = nil
    ) {
        self.invoiceId = ""
        self.customerId = customerId
        self.tokenId = tokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.additionalData = additionalData
    }

    /// Creates a request that can be used to authorize APM.
    /// - Parameters:
    ///   - tokenId: when value is set invoice is being authorized with previously tokenized APM.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        tokenId: String? = nil,
        additionalData: [String: String]? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.customerId = nil
        self.tokenId = tokenId
        self.additionalData = additionalData
    }
}
