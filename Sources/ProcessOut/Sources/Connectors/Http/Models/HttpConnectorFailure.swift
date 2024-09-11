//
//  HttpConnectorFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

enum HttpConnectorFailure: Error, Sendable {

    struct InvalidField: Decodable, Sendable {

        /// Field name.
        let name: String

        /// Message describing an error.
        let message: String
    }

    struct Server: Decodable, Sendable {

        /// Error type.
        let errorType: String

        /// Failure message.
        let message: String?

        /// Invalid fields if any.
        let invalidFields: [InvalidField]?
    }

    /// Unable to encode data.
    case encoding(Error)

    /// Unable to decode data.
    case decoding(Error, statusCode: Int)

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
