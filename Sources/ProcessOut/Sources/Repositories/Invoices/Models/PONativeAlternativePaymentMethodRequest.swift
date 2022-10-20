//
//  PONativeAlternativePaymentMethodRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

public struct PONativeAlternativePaymentMethodRequest {

    public enum ParameterValue {
        case int(Int), string(String)
    }

    /// Invoice id.
    public let invoiceId: String

    /// Gateway configuration id.
    public let gatewayConfigurationId: String

    /// Payment request parameters.
    public let parameters: [String: ParameterValue]

    /// Creates request instance.
    public init(invoiceId: String, gatewayConfigurationId: String, parameters: [String: ParameterValue]) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.parameters = parameters
    }
}

extension PONativeAlternativePaymentMethodRequest.ParameterValue: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .int(let value):
            try container.encode(value)
        case .string(let value):
            try container.encode(value)
        }
    }
}
