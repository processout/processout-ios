//
//  POSavedPaymentMethodsConfiguration.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 20.12.2024.
//

import ProcessOut

public struct POSavedPaymentMethodsConfiguration: Sendable {

    /// Requested invoice ID.
    public let invoiceId: String

    /// A secret key associated with the client making the request.
    ///
    /// This key ensures that the payment methods saved by the customer are
    /// included in the response if the invoice has an assigned customerID.
    public let clientSecret: String

    public init(invoiceId: String, clientSecret: String) {
        self.invoiceId = invoiceId
        self.clientSecret = clientSecret
    }
}
