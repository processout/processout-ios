//
//  HttpConnectorFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2022.
//

struct HttpConnectorFailure: Error {

    enum Code {

        /// Unable to encode data.
        case encoding

        /// Unable to decode data.
        case decoding(statusCode: Int)

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

    struct Server: Decodable {

        /// Error type.
        let errorType: String

        /// Failure message.
        let message: String?

        /// Invalid fields if any.
        let invalidFields: [InvalidField]?
    }

    struct InvalidField: Decodable {

        /// Field name.
        let name: String

        /// Message describing an error.
        let message: String
    }

    /// Failure code.
    let code: Code

    /// Underlying error.
    let underlyingError: Error?
}
