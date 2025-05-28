//
//  PONativeAlternativePaymentAuthorizationRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

@_spi(PO)
public struct PONativeAlternativePaymentAuthorizationRequestV2: Sendable, Encodable {

    public struct SubmitData: Sendable, Encodable {

        /// Parameters to submit.
        public let parameters: [String: Parameter]
    }

    public struct Parameter: Sendable {

        @_spi(PO)
        public enum Value: Sendable { // swiftlint:disable:this nesting

            public struct Phone: Encodable, Sendable { // swiftlint:disable:this nesting

                /// Phone dialing code.
                public let dialingCode: String

                /// Value.
                public let number: String

                public init(dialingCode: String, number: String) {
                    self.dialingCode = dialingCode
                    self.number = number
                }
            }

            case string(String), phone(Phone)
        }

        /// Parameter raw value.
        @_spi(PO)
        public let value: Value

        @_spi(PO)
        public init(value: Value) {
            self.value = value
        }
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

extension PONativeAlternativePaymentAuthorizationRequestV2.Parameter {

    public static func string(_ value: String) -> Self {
        .init(value: .string(value))
    }

    public static func phone(dialingCode: String, number: String) -> Self {
        .init(value: .phone(.init(dialingCode: dialingCode, number: number)))
    }
}

extension PONativeAlternativePaymentAuthorizationRequestV2.Parameter: Encodable {

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
