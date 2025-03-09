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
public struct POAlternativePaymentTokenizationRequest: Sendable, Codable {

    /// Customer ID that may be used for creating APM recurring token.
    public let customerId: String

    /// Customer token ID that may be used for creating APM recurring token.
    public let customerTokenId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// Additional data that will be supplied to the APM.
    public let additionalData: [String: String]?

    /// An object used to evaluate navigation events in a web authentication session.
    @POExcludedEncodable
    public private(set) var callback: POWebAuthenticationCallback?

    /// A boolean value that indicates whether the session should ask the browser for a
    /// private authentication session.
    ///
    /// Set `prefersEphemeralSession` to true to request that the browser
    /// doesn’t share cookies or other browsing data between the authentication session
    /// and the user’s normal browser session.
    ///
    /// The value of this property is `true` by default.
    @POExcludedEncodable
    public private(set) var prefersEphemeralSession: Bool

    /// Creates tokenization request.
    public init(
        customerId: String,
        customerTokenId: String,
        gatewayConfigurationId: String,
        additionalData: [String: String]? = nil,
        callback: POWebAuthenticationCallback? = nil,
        prefersEphemeralSession: Bool = true
    ) {
        self.customerId = customerId
        self.customerTokenId = customerTokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.additionalData = additionalData
        self.callback = callback
        self.prefersEphemeralSession = prefersEphemeralSession
    }
}
