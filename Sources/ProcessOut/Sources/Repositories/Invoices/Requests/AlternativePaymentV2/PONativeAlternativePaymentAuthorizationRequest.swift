//
//  PONativeAlternativePaymentAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

// swiftlint:disable nesting

@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationRequest: Sendable, Encodable {

    public struct SubmitData: Sendable, Encodable {

        /// Parameters to submit.
        public let parameters: [String: Parameter]
    }

    public struct Parameter: Sendable {

        enum Value {

            struct Phone: Encodable {

                /// Phone dialing code.
                let dialingCode: String

                /// Value.
                let value: String
            }

            case string(String), phone(Phone)
        }

        /// Parameter raw value.
        let value: Value
    }

    /// Invoice identifier.
    public let invoiceId: String

    /// Gateway configuration identifier.
    public let gatewayConfigurationId: String

    /// Payment request parameters.
    public let submitData: SubmitData?

    public init(invoiceId: String, gatewayConfigurationId: String, parameters: [String: Parameter]? = nil) {
        self.invoiceId = invoiceId
        self.gatewayConfigurationId = gatewayConfigurationId
        self.submitData = parameters.map(SubmitData.init)
    }
}

// swiftlint:enable nesting

extension PONativeAlternativePaymentAuthorizationRequest.Parameter {

    public static func string(_ value: String) -> Self {
        .init(value: .string(value))
    }

    public static func phone(dialingCode: String, value: String) -> Self {
        .init(value: .phone(.init(dialingCode: dialingCode, value: value)))
    }
}

extension PONativeAlternativePaymentAuthorizationRequest.Parameter: Encodable {

    public func encode(to encoder: any Encoder) throws {
        switch value {
        case .string(let value):
            var container = encoder.singleValueContainer()
            try container.encode(value)
        case .phone(let phone):
            var container = encoder.singleValueContainer()
            try container.encode(phone)
        }
    }
}
