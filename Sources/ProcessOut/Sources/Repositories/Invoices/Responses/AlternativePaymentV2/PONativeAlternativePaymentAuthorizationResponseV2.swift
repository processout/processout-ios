//
//  PONativeAlternativePaymentAuthorizationResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 13.05.2025.
//

import Foundation

public struct PONativeAlternativePaymentAuthorizationResponseV2: Sendable, Decodable {

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Payment method information.
    public let paymentMethod: PONativeAlternativePaymentMethodV2

    /// Invoice information.
    public let invoice: PONativeAlternativePaymentInvoiceV2

    /// UI elements.
    public let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    public let redirect: PONativeAlternativePaymentRedirectV2?
}
