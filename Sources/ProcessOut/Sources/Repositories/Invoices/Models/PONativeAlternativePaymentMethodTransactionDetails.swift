//
//  PONativeAlternativePaymentMethodTransactionDetails.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 30.11.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodTransactionDetails: Decodable {

    /// Payment gateway information.
    public struct Gateway: Decodable {

        /// Name of the payment gateway that can be displayed.
        public let displayName: String

        /// Gateway's logo URL.
        public let logoUrl: URL
    }

    /// Invoice details.
    public struct Invoice: Decodable {

        /// Invoice amount.
        @ImmutableStringCodableDecimal
        public var amount: Decimal

        /// Invoice currency code.
        public let currencyCode: String
    }

    /// Payment's state.
    public let state: NativeAlternativePaymentMethodState?

    /// Gateway details.
    public let gateway: Gateway

    /// Invoice details.
    public let invoice: Invoice

    /// Parameters that are expected from user.
    public let nativeApmPparameters: [PONativeAlternativePaymentMethodParameter]
}
