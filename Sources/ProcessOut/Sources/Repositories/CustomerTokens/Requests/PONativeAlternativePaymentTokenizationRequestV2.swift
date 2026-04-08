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

    /// Alternative payment configuration.
    ///
    /// - WARNING: Configuration is respected only with the **FIRST** request for the payment, ignored for
    /// subsequent ones.
    public let configuration: PONativeAlternativePaymentConfigurationV2

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
        configuration: PONativeAlternativePaymentConfigurationV2 = .init(),
        submitData: PONativeAlternativePaymentSubmitDataV2? = nil,
        redirect: PONativeAlternativePaymentRedirectResultV2? = nil,
        localeIdentifier: String? = nil
    ) {
        self.customerId = customerId
        self.customerTokenId = customerTokenId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.configuration = configuration
        self.submitData = submitData
        self.redirect = redirect
        self.localeIdentifier = localeIdentifier
    }
}
