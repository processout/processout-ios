//
//  PONativeAlternativePaymentMethodRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

public struct PONativeAlternativePaymentMethodRequest: Sendable, Codable {

    /// Invoice id.
    public let invoiceId: String

    /// Gateway configuration id.
    public let gatewayConfigurationId: String

    /// Payment request parameters.
    public let parameters: [String: String]

    /// Creates request instance.
    public init(invoiceId: String, gatewayConfigurationId: String, parameters: [String: String]) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.parameters = parameters
    }
}
