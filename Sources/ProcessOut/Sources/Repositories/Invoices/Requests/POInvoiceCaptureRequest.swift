//
//  POInvoiceCaptureRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 21.09.2026.
//

@_spi(PO)
public struct POInvoiceCaptureRequest: Sendable {

    /// Invoice identifier.
    public let invoiceId: String

    /// Payment source, for example gateway configuration identifier or customer token identifier.
    public let source: String

    public init(invoiceId: String, source: String) {
        self.invoiceId = invoiceId
        self.source = source
    }
}
