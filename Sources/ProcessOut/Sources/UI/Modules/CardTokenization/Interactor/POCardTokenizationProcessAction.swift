//
//  POCardTokenizationProcessAction.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.08.2023.
//

/// Defines possible actions to perform with tokenized card.
@_spi(PO)
public enum POCardTokenizationProcessAction {

    /// Use this action to authorize an invoice.
    case authorizeInvoice(POInvoiceAuthorizationRequest)

    /// Use this action to assign customer token.
    case assignToken(POAssignCustomerTokenRequest)
}
