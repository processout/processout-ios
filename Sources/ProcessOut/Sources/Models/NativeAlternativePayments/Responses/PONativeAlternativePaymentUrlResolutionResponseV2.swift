//
//  PONativeAlternativePaymentUrlResolutionResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2026.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentUrlResolutionResponseV2: Sendable, Decodable {

    public struct CustomerToken: Sendable, Decodable {

        /// Customer token ID.
        public let id: POCustomerToken.ID
    }

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Payment method information.
    public let paymentMethod: PONativeAlternativePaymentMethodV2

    /// Invoice information if available.
    public let invoice: PONativeAlternativePaymentInvoiceV2?

    /// Customer token information if any.
    public let customerToken: CustomerToken?

    /// UI elements to display to user.
    public let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    public let redirect: PONativeAlternativePaymentRedirectV2?
}
