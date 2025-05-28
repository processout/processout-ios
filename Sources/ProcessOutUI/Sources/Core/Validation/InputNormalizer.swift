//
//  InputNormalizer.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 27.05.2025.
//

/// A protocol that defines a mechanism for normalizing input values into a desired format.
///
/// Conforming types are responsible for transforming raw input into a standardized or cleaned form
/// before further processing, such as validation or persistence.
protocol InputNormalizer: Sendable {

    /// The type of the raw input to be normalized.
    associatedtype Input

    /// The type of the normalized output.
    associatedtype Output

    /// Normalizes the provided input value.
    ///
    /// - Parameter input: The raw input to normalize.
    /// - Returns: The normalized output.
    func normalize(input: Input) -> Output
}
