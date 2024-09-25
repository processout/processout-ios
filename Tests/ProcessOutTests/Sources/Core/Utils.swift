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
func assertThrowsError<T, E: Error>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    errorType: E.Type = Error.self,
    file: StaticString = #filePath,
    line: UInt = #line
) async -> E? {
    do {
        _ = try await expression()
    } catch let error as E {
        return error
    } catch {
        XCTFail("Unexpected error type")
    }
    XCTFail(message(), file: file, line: line)
    return nil
}
