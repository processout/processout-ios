//
//  PONativeAlternativePaymentTokenizationRequestV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

public struct PONativeAlternativePaymentTokenizationRequestV2: Sendable, Encodable {

    /// Customer ID.
    public let customerId: String

    /// Customer token ID.
    public let customerTokenId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    /// Payment request parameters.
    public let submitData: PONativeAlternativePaymentSubmitDataV2?

    /// Redirect result.
    public let redirect: PONativeAlternativePaymentRedirectResultV2?

    /// Customer's locale identifier override.
    @POExcludedEncodable
    public private(set) var localeIdentifier: String?

    public init(
        customerId: String,
        customerTokenId: String,
        gatewayConfigurationId: String,
        submitData: PONativeAlternativePaymentSubmitDataV2? = nil,
        redirect: PONativeAlternativePaymentRedirectResultV2? = nil,
        localeIdentifier: String? = nil
    ) {
        self.customerId = customerId
        self.customerTokenId = customerTokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.submitData = submitData
        self.redirect = redirect
        self.localeIdentifier = localeIdentifier
    }
}
