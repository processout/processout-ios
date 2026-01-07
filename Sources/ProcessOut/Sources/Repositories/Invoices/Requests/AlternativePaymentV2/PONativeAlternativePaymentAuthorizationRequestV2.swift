//
//  PONativeAlternativePaymentAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

public struct PONativeAlternativePaymentAuthorizationRequestV2: Sendable, Encodable {

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    /// Payment source.
    public let source: String?

    /// Payment request parameters.
    public let submitData: PONativeAlternativePaymentSubmitDataV2?

    /// Redirect result.
    public let redirect: PONativeAlternativePaymentRedirectResultV2?

    /// Customer's locale identifier override.
    @POExcludedEncodable
    public private(set) var localeIdentifier: String?

    public init(
        invoiceId: String,
        gatewayConfigurationId: String,
        source: String? = nil,
        submitData: PONativeAlternativePaymentSubmitDataV2? = nil,
        redirect: PONativeAlternativePaymentRedirectResultV2? = nil,
        localeIdentifier: String? = nil
    ) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.source = source
        self.submitData = submitData
        self.redirect = redirect
        self.localeIdentifier = localeIdentifier
    }
}
