//
//  POCardTokenizationDelegate.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 09.08.2023.
//

@_spi(PO)
public protocol POCardTokenizationDelegate: AnyObject {

    /// Allows delegate to authorize invoice using card details provided by user.
    func invoiceAuthorizationRequest(card: POCard) -> POInvoiceAuthorizationRequest?
}
