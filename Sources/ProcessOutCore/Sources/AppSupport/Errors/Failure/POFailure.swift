//
//  POFailure.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 12.10.2022.
//

import Foundation

/// Information about an error that occurred.
@available(iOS 15, *)
@_originallyDefinedIn(module: "ProcessOut", iOS 15)
public struct POFailure: LocalizedError {

    public struct InvalidField: Codable, Sendable {

        /// Field name.
        public let name: String

        /// Message describing an error.
        public let message: String

        package init(name: String, message: String) {
            self.name = name
            self.message = message
        }
    }

    /// Failure message. Not intented to be used as a user facing string.
    public let message: String?

    /// Localized error description if any.
    public let errorDescription: String?

    /// Failure code.
    public let failureCode: POFailureCode

    /// Invalid fields if any.
    public let invalidFields: [InvalidField]?

    /// Underlying error for inspection.
    public let underlyingError: Error?

    /// Creates failure instance.
    public init(
        message: String? = nil,
        errorDescription: String? = nil,
        code: POFailureCode,
        invalidFields: [InvalidField]? = nil,
        underlyingError: Error? = nil
    ) {
        self.message = message
        self.errorDescription = errorDescription
        self.failureCode = code
        self.invalidFields = invalidFields
        self.underlyingError = underlyingError
    }
}

extension POFailure: Codable {

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        message = try container.decodeIfPresent(String.self, forKey: .message)
        errorDescription = nil
        failureCode = try container.decode(POFailureCode.self, forKey: .code)
        invalidFields = try container.decodeIfPresent([InvalidField].self, forKey: .invalidFields)
        underlyingError = nil
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(message, forKey: .message)
        try container.encode(failureCode, forKey: .code)
        try container.encodeIfPresent(invalidFields, forKey: .invalidFields)
    }

    // MARK: - Private Properties

    private enum CodingKeys: String, CodingKey {
        case message, code, invalidFields
    }
}

extension POFailure: CustomDebugStringConvertible {

    public var debugDescription: String {
        let parameters = [
            ("code", failureCode.rawValue),
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
