//
//  POInvoiceRequest.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 18.04.2024.
//

/// Request to get single invoice details.
public struct POInvoiceRequest {

    /// Requested invoice ID.
    public let invoiceId: String

    /// A secret key associated with the client making the request.
    ///
    /// This key ensures that the payment methods saved by the customer are
    /// included in the response if the invoice has an assigned customerID.
    public let clientSecret: String?

    /// Creates request instance.
    public init(invoiceId: String, clientSecret: String? = nil) {
        self.invoiceId = invoiceId
        self.clientSecret = clientSecret
    }
}
