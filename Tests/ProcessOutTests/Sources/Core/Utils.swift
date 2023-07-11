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
///   - errorHandler: An optional handler for errors that expression throws.
func assertThrowsError<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (_ error: Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
    } catch {
        errorHandler(error)
        return
    }
    XCTFail(message(), file: file, line: line)
}
