//
//  AsyncUtilsTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 11.12.2023.
//

@testable import ProcessOut
import XCTest

final class AsyncUtilsTests: XCTestCase {

    // MARK: - Timeout

    func test_withTimeout_whenOperationCompletesBeforeTimeout_ignoresTimeout() async throws {
        // Given
        let timeout: TimeInterval = 10
        let operationDuration: TimeInterval = 1

        // When
        let value = try await withTimeout(timeout, error: Failure.timeout) {
            try? await Task.sleep(for: .seconds(operationDuration))
            return "value"
        }

        // Then
        XCTAssertEqual(value, "value")
    }

    func test_withTimeout_whenCancellableOperationTimesOut_throwsError() async {
        // Given
        let timeout: TimeInterval = 1
        let operation = { @Sendable in
            try await Task.sleep(for: .seconds(3))
        }

        // When
        let error = await assertThrowsError(
            try await withTimeout(timeout, error: Failure.timeout, perform: operation)
        )

        // Then
        if let failure = error as? Failure, failure == .timeout {
            return
        }
        XCTFail("Expected timeout failure.")
    }

    func test_withTimeout_whenNonCancellableOperationTimesOut_ignoresTimeout() async throws {
        // Given
        let timeout: TimeInterval = 1
        let operationDuration: TimeInterval = 3

        // When
        try await withTimeout(timeout, error: Failure.timeout) {
            try? await Task.sleep(for: .seconds(operationDuration))
        }
    }

    func test_withTimeout_whenOperationIsCancelledBeforeTimeout_propagatesError() async throws {
        // Given
        let timeout: TimeInterval = 1
        let operation = { @Sendable in
            try await Task.sleep(for: .seconds(3))
        }

        // When
        let task = Task {
            try await withTimeout(timeout, error: Failure.timeout, perform: operation)
        }
        task.cancel()

        // Then
        switch await task.result {
        case .failure(let error) where error is CancellationError:
            break
        default:
            XCTFail("Expected cancellation error")
        }
    }

    func test_withTimeout_whenOperationThrowsBeforeTimeout_propagatesError() async throws {
        // Given
        let timeout: TimeInterval = 3
        let operation = { @Sendable in
            try? await Task.sleep(for: .seconds(1))
            throw Failure.generic
        }

        // When
        let task = Task {
            try await withTimeout(timeout, error: Failure.timeout, perform: operation)
        }

        // Then
        switch await task.result {
        case .failure(let failure as Failure) where failure == .generic:
            break
        default:
            XCTFail("Expected generic error")
        }
    }

    // MARK: - Private Nested Types

    private enum Failure: Error {
        case timeout, generic
    }
}
