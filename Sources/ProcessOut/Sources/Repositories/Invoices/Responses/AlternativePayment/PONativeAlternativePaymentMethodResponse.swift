//
//  PONativeAlternativePaymentMethodResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodResponse: Codable, Sendable {

    /// Payment's state.
    public let state: PONativeAlternativePaymentMethodState

    /// Contains details about the additional information you need to collect from your customer before creating the
    /// payment request.
    public let parameterDefinitions: [PONativeAlternativePaymentMethodParameter]?

    /// Additional information about payment step.
    public let parameterValues: PONativeAlternativePaymentMethodParameterValues?
}

extension PONativeAlternativePaymentMethodResponse {

    @available(*, deprecated, message: "Use PONativeAlternativePaymentMethodParameterValues directly.")
    public typealias NativeAlternativePaymentMethodParameterValues = PONativeAlternativePaymentMethodParameterValues

    @available(*, deprecated, message: "Use PONativeAlternativePaymentMethodResponse directly.")
    public typealias NativeApm = PONativeAlternativePaymentMethodResponse

    /// Details for alternative payment method.
    @available(*, deprecated, message: "Access PONativeAlternativePaymentMethodResponse properties directly.")
    public var nativeApm: NativeApm {
        self
    }
}
