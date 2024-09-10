//
//  PODynamicCheckoutInvoiceInvalidationReason.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.08.2024.
//

import ProcessOut

/// Invoice invalidation reason.
@_spi(PO)
public enum PODynamicCheckoutInvoiceInvalidationReason: Sendable {

    /// User requested different payment method selection that requires new invoice.
    case paymentMethodChanged

    /// Selected method failed and payment can't be continued with current invoice.
    case failure(POFailure)
}
