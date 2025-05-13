//
//  JwkEncodingError.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 25.04.2025.
//

/// An error that occurs during the encoding of a JWK
enum JwkEncodingError: Error {

    /// The context in which the error occurred.
    struct Context: Sendable {

        /// A description of what went wrong, for debugging purposes.
        let debugDescription: String

        /// The underlying error which caused this error, if any.
        let underlyingError: Error?
    }

    /// An indication that the data is corrupted or otherwise invalid.
    case dataCorrupted(Context)

    static func dataCorruptedError(debugDescription: String, underlyingError: Error? = nil) -> JwkEncodingError {
        let context = Context(debugDescription: debugDescription, underlyingError: underlyingError)
        return .dataCorrupted(context)
    }
}
