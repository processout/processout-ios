//
//  HttpConnectorFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

enum HttpConnectorFailure: Error {

    struct InvalidField: Decodable {

        /// Field name.
        let name: String

        /// Message describing an error.
        let message: String
    }

    struct Server: Decodable {

        /// Error type.
        let errorType: String

        /// Failure message.
        let message: String?

        /// Invalid fields if any.
        let invalidFields: [InvalidField]?
    }

    /// Unable to code data. Supplied error is going to be `DecodingError` or `EncodingError`.
    case coding(Error)

    /// No network connection.
    case networkUnreachable

    /// Request didn't finish in time.
    case timeout

    /// Server error.
    case server(Server, statusCode: Int)

    /// Cancellation error.
    case cancelled

    /// Internal error.
    case `internal`
}
