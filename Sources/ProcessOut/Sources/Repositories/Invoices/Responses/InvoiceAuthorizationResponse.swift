//
//  InvoiceAuthorizationResponse.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 23.02.2026.
//

struct InvoiceAuthorizationResponse: Decodable, Sendable {

    /// Optional customer action.
    let customerAction: _CustomerAction?

    /// Optional customer token id, if invoice was authorized with `saveSource` flag set to `true`,
    /// and implementation was able to tokenize authorization source.
    let customerTokenId: String?
}
