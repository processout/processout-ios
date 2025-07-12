//
//  ParameterValue.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.06.2025.
//

public enum PONativeAlternativePaymentParameterValue: Equatable, Sendable {

    public struct Phone: Equatable, Sendable {

        public init(regionCode: String? = nil, number: String? = nil) {
            self.regionCode = regionCode
            self.number = number
        }

        /// Selected region code.
        public let regionCode: String?

        /// National phone number value.
        public let number: String?
    }

    case string(String), phone(Phone)

    // MARK: - Unknown Future Case

    /// Placeholder to allow adding additional payment methods while staying backward compatible.

    @_spi(PO)
    case unknown
}
