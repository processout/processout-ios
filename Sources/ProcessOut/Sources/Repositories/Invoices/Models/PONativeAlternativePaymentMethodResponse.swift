//
//  PONativeAlternativePaymentMethodResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodResponse: Decodable {

    public struct NativeAlternativePaymentMethodParameterValues: Decodable {

        /// Message.
        public let message: String?
    }

    public struct NativeApm: Decodable {

        /// Payment's state.
        public let state: NativeAlternativePaymentMethodState

        /// Contains details about the additional information you need to collect from your customer before creating the
        /// payment request.
        public let parameterDefinitions: [PONativeAlternativePaymentMethodParameter]?

        /// Additional information about payment step.
        public let parameterValues: NativeAlternativePaymentMethodParameterValues?
    }

    /// Details for alternative payment method.
    public let nativeApm: NativeApm
}
