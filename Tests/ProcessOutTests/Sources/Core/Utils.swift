//
//  Utils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 07.07.2023.
//

import XCTest

/// Asserts that an expression throws an error.
/// - Parameters:
///   - expression: An expression that can throw an error.
///   - message: An optional description of a failure.
@discardableResult
func assertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line
) async -> Error? {
    do {
        _ = try await expression()
    } catch {
        return error
    }
    XCTFail(message(), file: file, line: line)
    return nil
}
