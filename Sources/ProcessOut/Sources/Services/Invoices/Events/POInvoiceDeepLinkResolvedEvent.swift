//
//  POInvoiceDeepLinkResolvedEvent.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.03.2026.
//

@_spi(PO)
public struct POInvoiceDeepLinkResolvedEvent: POEventEmitterEvent {

    /// Resolved invoice ID.
    public let invoiceId: POInvoice.ID

    /// Customer token ID.
    public let customerTokenId: POCustomerToken.ID?
}
