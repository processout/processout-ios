//
//  POInvoiceAuthorizationResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.02.2026.
//

public struct POInvoiceAuthorizationResponse: Sendable {

    /// Optional customer token id, if invoice was authorized with `saveSource` flag set to `true`,
    /// and implementation was able to tokenize the source.
    public let customerTokenId: String?

    /// Invoice authorization outcome.
    public let outcome: POInvoiceAuthorizationOutcome
}
