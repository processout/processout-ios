//
//  AsyncUtilsTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 11.12.2023.
//

@testable @_spi(PO) import ProcessOut
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

    // MARK: - Retry

    func test_retry_whenTimeoutIsZero_executesOperationOnce() async throws {
        // Given
        let isOperationExecuted = POUnfairlyLocked<Bool>(wrappedValue: false)

        // When
        try await retry(
            operation: {
                isOperationExecuted.withLock { $0 = true }
            },
            while: { _ in
                false
            },
            timeout: 0,
            timeoutError: Failure.timeout
        )

        // Then
        XCTAssertTrue(isOperationExecuted.wrappedValue)
    }

    func test_retry_whenTimesOut_throwsTimeoutError() async {
        // When
        let error = await assertThrowsError(
            try await retry(
                operation: {
                    try await Task.sleep(for: .seconds(3))
                },
                while: { _ in false },
                timeout: 1,
                timeoutError: Failure.timeout
            )
        )

        // Then
        if let failure = error as? Failure, failure == .timeout {
            return
        }
        XCTFail("Expected timeout failure.")
    }

    func test_retry_checksRetryCondition_whenRetryStrategyIsSet() async throws {
        // Given
        let isConditionChecked = POUnfairlyLocked<Bool>(wrappedValue: false)

        // When
        _ = try await retry(
            operation: {
                ""
            },
            while: { _ in
                isConditionChecked.withLock { $0 = true }
                return false
            },
            timeout: 10,
            timeoutError: Failure.timeout,
            retryStrategy: .linear(maximumRetries: 1, interval: 0)
        )

        // Then
        XCTAssertTrue(isConditionChecked.wrappedValue)
    }

    func test_retry_retriesOperation_whenRetryStrategyIsSet() async throws {
        // Given
        let operationStartsCount = POUnfairlyLocked<Int>(wrappedValue: 0)

        // When
        _ = try await retry(
            operation: {
                operationStartsCount.withLock { $0 += 1 }
            },
            while: { _ in
                true
            },
            timeout: 10,
            timeoutError: Failure.timeout,
            retryStrategy: .linear(maximumRetries: 1, interval: 0)
        )

        // Then
        XCTAssertEqual(operationStartsCount.wrappedValue, 2)
    }

    // swiftlint:disable:next line_length
    func test_retry_whenCancelledDuringRetryDelayAndOperationIsCancellable_completesWithCancellationError() async throws {
        // Given
        let task = Task {
            try await retry(
                operation: {
                    try Task.checkCancellation()
                    return ""
                },
                while: { _ in
                    true
                },
                timeout: 10,
                timeoutError: Failure.timeout,
                retryStrategy: .linear(maximumRetries: 1, interval: 5)
            )
        }

        // When
        try await Task.sleep(for: .seconds(1))
        task.cancel()

        // Then
        if case .failure(let failure) = await task.result, failure is CancellationError {
            return
        }
        XCTFail("Expected cancellation error")
    }

    func test_retry_whenRetryCountIsExceeded_completesWithRecentResult() async throws {
        // Given
        let recentOperationValue = POUnfairlyLocked<String>(wrappedValue: "")

        // When
        let value = try await retry(
            operation: {
                recentOperationValue.withLock { value in
                    value = UUID().uuidString
                    return value
                }
            },
            while: { _ in
                true
            },
            timeout: 10,
            timeoutError: Failure.timeout,
            retryStrategy: .linear(maximumRetries: 1, interval: 0)
        )

        // Then
        XCTAssertEqual(recentOperationValue.wrappedValue, value)
    }

    func test_retry_whenRetryConditionResolvesFalse_completesWithRecentResult() async throws {
        // Given
        let recentOperationValue = POUnfairlyLocked<String>(wrappedValue: "")

        // When
        let value = try await retry(
            operation: {
                recentOperationValue.withLock { value in
                    value = UUID().uuidString
                    return value
                }
            },
            while: { _ in
                false
            },
            timeout: 10,
            timeoutError: Failure.timeout,
            retryStrategy: .linear(maximumRetries: 1, interval: 0)
        )

        // Then
        XCTAssertEqual(recentOperationValue.wrappedValue, value)
    }

    func test_retry_whenCancelledImmediately_completesWithCancellationError() async throws {
        // Given
        let task = Task {
            try await retry(
                operation: {
                    try await Task.sleep(for: .seconds(1))
                },
                while: { _ in
                    true
                },
                timeout: 10,
                timeoutError: Failure.timeout
            )
        }

        // When
        task.cancel()

        // Then
        if case .failure(let failure) = await task.result, failure is CancellationError {
            return
        }
        XCTFail("Expected cancellation error")
    }

    // MARK: - Private Nested Types

    private enum Failure: Error {
        case timeout, generic, cancel
    }
}
