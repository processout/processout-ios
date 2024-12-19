//
//  AsyncUtilsTests.swift
//  ProcessOutTests
//
//  Created by Andrii Vysotskyi on 11.12.2023.
//

import Foundation
import Testing
@testable @_spi(PO) import ProcessOut

struct AsyncUtilsTests {

    // MARK: - Timeout

    @Test
    func withTimeout_whenOperationCompletesBeforeTimeout_ignoresTimeout() async throws {
        // Given
        let timeout: TimeInterval = 10
        let operationDuration: TimeInterval = 1

        // When
        let value = try await withTimeout(timeout, error: Failure.timeout) {
            try? await Task.sleep(for: .seconds(operationDuration))
            return "value"
        }

        // Then
        #expect(value == "value")
    }

    @Test
    func withTimeout_whenCancellableOperationTimesOut_throwsError() async throws {
        // Given
        let timeout: TimeInterval = 1
        let operation = { @Sendable in
            try await Task.sleep(for: .seconds(3))
        }

        // When
        try await withKnownIssue {
            try await withTimeout(timeout, error: Failure.timeout, perform: operation)
        } matching: { issue in
            if let failure = issue.error as? Failure, failure == .timeout {
                return true
            }
            return false
        }
    }

    @Test
    func withTimeout_whenNonCancellableOperationTimesOut_ignoresTimeout() async throws {
        // Given
        let timeout: TimeInterval = 1
        let operationDuration: TimeInterval = 3

        // When
        try await withTimeout(timeout, error: Failure.timeout) {
            try? await Task.sleep(for: .seconds(operationDuration))
        }
    }

    @Test
    func withTimeout_whenOperationIsCancelledBeforeTimeout_propagatesError() async throws {
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
            Issue.record("Expected cancellation error.")
        }
    }

    @Test
    func withTimeout_whenOperationThrowsBeforeTimeout_propagatesError() async throws {
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
            Issue.record("Expected generic error.")
        }
    }

    // MARK: - Retry

    @Test
    func retry_whenTimeoutIsZero_executesOperationOnce() async throws {
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
        #expect(isOperationExecuted.wrappedValue)
    }

    @Test
    func retry_whenTimesOut_throwsTimeoutError() async throws {
        // When
        try await withKnownIssue {
            try await retry(
                operation: {
                    try await Task.sleep(for: .seconds(3))
                },
                while: { _ in false },
                timeout: 1,
                timeoutError: Failure.timeout
            )
        } matching: { issue in
            if let failure = issue.error as? Failure, failure == .timeout {
                return true
            }
            return false
        }
    }

    @Test
    func retry_checksRetryCondition_whenRetryStrategyIsSet() async throws {
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
            retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1, minimum: 0)
        )

        // Then
        #expect(isConditionChecked.wrappedValue)
    }

    @Test
    func retry_retriesOperation_whenRetryStrategyIsSet() async throws {
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
            retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1, minimum: 0)
        )

        // Then
        #expect(operationStartsCount.wrappedValue == 2)
    }

    @Test
    func retry_whenCancelledDuringRetryDelayAndOperationIsCancellable_completesWithCancellationError() async throws {
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
                retryStrategy: .init(function: .linear(interval: 5), maximumRetries: 1)
            )
        }

        // When
        try await Task.sleep(for: .seconds(1))
        task.cancel()

        // Then
        if case .failure(let failure) = await task.result, failure is CancellationError {
            return
        }
        Issue.record("Expected cancellation error.")
    }

    @Test
    func retry_whenRetryCountIsExceeded_completesWithRecentResult() async throws {
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
            retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1, minimum: 0)
        )

        // Then
        #expect(recentOperationValue.wrappedValue == value)
    }

    @Test
    func retry_whenRetryConditionResolvesFalse_completesWithRecentResult() async throws {
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
            retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 1, minimum: 0)
        )

        // Then
        #expect(recentOperationValue.wrappedValue == value)
    }

    @Test
    func retry_whenCancelledImmediately_completesWithCancellationError() async throws {
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
        Issue.record("Expected cancellation error.")
    }

    // MARK: - Private Nested Types

    private enum Failure: Error {
        case timeout, generic, cancel
    }
}
