//
//  PONativeAlternativePaymentTokenizationResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.06.2025.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentTokenizationResponseV2: Sendable, Decodable {

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Payment method information.
    public let paymentMethod: PONativeAlternativePaymentMethodV2

    /// Next step if any.
    public let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    public let redirect: PONativeAlternativePaymentRedirectV2?
}
