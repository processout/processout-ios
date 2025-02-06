//
//  POFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

/// Information about an error that occurred.
public struct POFailure: Error {

    public struct InvalidField: Decodable, Sendable {

        /// Field name.
        public let name: String

        /// Message describing an error.
        public let message: String

        @_spi(PO)
        public init(name: String, message: String) {
            self.name = name
            self.message = message
        }
    }

    /// Failure message. Not intented to be used as a user facing string.
    public let message: String?

    /// Failure code.
    public let failureCode: POFailureCode

    /// Invalid fields if any.
    public let invalidFields: [InvalidField]?

    /// Underlying error for inspection.
    public let underlyingError: Error?

    /// Creates failure instance.
    public init(
        message: String? = nil,
        code: POFailureCode,
        invalidFields: [InvalidField]? = nil,
        underlyingError: Error? = nil
    ) {
        self.message = message
        self.failureCode = code
        self.invalidFields = invalidFields
        self.underlyingError = underlyingError
    }
}

extension POFailure: CustomDebugStringConvertible {

    public var debugDescription: String {
        let parameters = [
            ("code", code.rawValue),
            ("message", message),
            ("underlyingError", underlyingError.map(String.init(describing:)))
        ]
        let parametersDescription = parameters
            .compactMap { name, value -> String? in
                guard let value else {
                    return nil
                }
                return "\(name): '\(value)'"
            }
            .joined(separator: ", ")
        return "POFailure(\(parametersDescription))"
    }
}
