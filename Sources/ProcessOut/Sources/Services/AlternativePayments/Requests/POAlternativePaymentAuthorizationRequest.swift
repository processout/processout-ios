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
public struct POAlternativePaymentAuthorizationRequest: Sendable, Codable {

    /// Invoice identifier to to perform APM payment for.
    public let invoiceId: String

    /// Gateway Configuration ID of the APM the payment will be made on.
    public let gatewayConfigurationId: String

    /// When value is set invoice is being authorized with previously tokenized APM.
    public let customerTokenId: String?

    /// Additional Data that will be supplied to the APM.
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

    /// Creates authorization request.
    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        customerTokenId: String? = nil,
        additionalData: [String: String]? = nil,
        callback: POWebAuthenticationCallback? = nil,
        prefersEphemeralSession: Bool = true
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.customerTokenId = customerTokenId
        self.additionalData = additionalData
        self.callback = callback
        self.prefersEphemeralSession = prefersEphemeralSession
    }
}
