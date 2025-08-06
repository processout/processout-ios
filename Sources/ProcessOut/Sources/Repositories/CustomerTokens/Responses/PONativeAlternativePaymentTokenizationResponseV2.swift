//
//  PONativeAlternativePaymentTokenizationResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

import Foundation

public struct PONativeAlternativePaymentTokenizationResponseV2: Sendable, Decodable {

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Payment method information.
    public let paymentMethod: PONativeAlternativePaymentMethodV2

    /// UI elements to display to user.
    public let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    public let redirect: PONativeAlternativePaymentRedirectV2?

    /// Polling information.
    public let polling: PONativeAlternativePaymentPollingV2?
}
