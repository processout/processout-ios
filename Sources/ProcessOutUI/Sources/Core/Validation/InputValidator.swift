//
//  InputValidator.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

/// A protocol that defines a type-safe interface for validating user input.
protocol InputValidator: Sendable {

    associatedtype Input

    /// Validates the provided input.
    ///
    /// - Parameter input: The value to validate.
    /// - Returns: A `InputValidation` result indicating whether the input is valid or contains an error.
    func validate(_ input: Input) -> InputValidation
}

/// Represents the result of validating an input value.
enum InputValidation: Sendable {

    /// Indicates that the input is valid.
    case valid

    /// Indicates that the input is invalid, along with an associated error message.
    case invalid(errorMessage: String)
}

extension InputValidation {

    /// The associated error message if the validation failed.
    ///
    /// - Returns: The error message if the case is `.invalid`, otherwise `nil`.
    var errorMessage: String? {
        if case .invalid(let errorMessage) = self {
            return errorMessage
        }
        return nil
    }
}
