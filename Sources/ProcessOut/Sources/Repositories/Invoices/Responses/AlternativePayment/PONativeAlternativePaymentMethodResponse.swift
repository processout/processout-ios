//
//  PONativeAlternativePaymentMethodResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 17.10.2022.
//

import Foundation

public struct PONativeAlternativePaymentMethodResponse: Decodable, Sendable {

    /// Payment's state.
    public let state: PONativeAlternativePaymentMethodState

    /// Contains details about the additional information you need to collect from your customer before creating the
    /// payment request.
    public let parameterDefinitions: [PONativeAlternativePaymentMethodParameter]?

    /// Additional information about payment step.
    public let parameterValues: PONativeAlternativePaymentMethodParameterValues?
}
