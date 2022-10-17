//
//  HttpConnectorFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

enum HttpConnectorFailure: Error {

    struct External: Decodable {

        /// Error type.
        let errorType: String

        /// Failure message.
        let message: String?
    }

    /// Unable to code data. Supplied error is going to be `DecodingError` or `EncodingError`.
    case coding(Error)

    /// Either there's no network connection, or request didn't finish in time.
    case networkUnreachable

    /// External error.
    case external(External, statusCode: Int)

    /// Cancellation error.
    case cancelled

    /// Internal error.
    case `internal`
}
