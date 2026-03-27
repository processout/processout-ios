//
//  PONativeAlternativePaymentUrlResolutionResponseV2.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.03.2026.
//

import Foundation

@_spi(PO)
public struct PONativeAlternativePaymentUrlResolutionResponseV2: Sendable, Decodable {

    public struct Payment: Sendable, Decodable {

        /// Invoice ID.
        public let invoiceId: POInvoice.ID

        /// Customer token ID if any.
        public let customerTokenId: POCustomerToken.ID?
    }

    /// Payment state.
    public let state: PONativeAlternativePaymentStateV2

    /// Payment method information.
    public let paymentMethod: PONativeAlternativePaymentMethodV2

    /// Invoice information if available.
    public let invoice: PONativeAlternativePaymentInvoiceV2?

    /// UI elements to display to user.
    public let elements: [PONativeAlternativePaymentElementV2]?

    /// Redirect details.
    public let redirect: PONativeAlternativePaymentRedirectV2?

    /// Payment information.
    public let payment: Payment
}
