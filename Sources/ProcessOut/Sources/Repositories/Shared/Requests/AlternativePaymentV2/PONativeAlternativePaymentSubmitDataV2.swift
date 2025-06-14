//
//  PONativeAlternativePaymentSubmitDataV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 28.05.2025.
//

public struct PONativeAlternativePaymentSubmitDataV2: Sendable, Encodable {

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

    /// Parameters to submit.
    public let parameters: [String: Parameter]

    public init(parameters: [String: Parameter]) {
        self.parameters = parameters
    }
}

extension PONativeAlternativePaymentSubmitDataV2.Parameter {

    public static func string(_ value: String) -> Self {
        .init(value: .string(value))
    }

    public static func phone(dialingCode: String, number: String) -> Self {
        .init(value: .phone(.init(dialingCode: dialingCode, number: number)))
    }
}

extension PONativeAlternativePaymentSubmitDataV2.Parameter: Encodable {

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
