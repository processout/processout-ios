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
        let value = try await withTimeout(timeout, error: Failure.timeout as any Error) {
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
            try await Task.sleep(for: .seconds(10))
        }

        // When
        try await withKnownIssue {
            try await withTimeout(timeout, error: Failure.timeout as any Error, perform: operation)
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
        try await withTimeout(timeout, error: Failure.timeout as any Error) {
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
            try await withTimeout(timeout, error: Failure.timeout as any Error, perform: operation)
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
            try await withTimeout(timeout, error: Failure.timeout as any Error, perform: operation)
        }

        // Then
        switch await task.result {
        case .failure(let failure as Failure) where failure == .generic:
            break
        default:
            Issue.record("Expected generic error.")
        }
    }

    @Test
    func withTimeout_whenTimedOutOperationThrowsOnCancellation_throwsTypedTimeoutError() async {
        // Given
        let operation = { @Sendable () async throws(Failure) in
            do {
                try await Task.sleep(for: .seconds(10))
            } catch {
                throw Failure.cancel
            }
        }

        // When
        do throws(Failure) {
            try await withTimeout(0.2, error: Failure.timeout, perform: operation)
            Issue.record("Expected timeout error.")
        } catch {
            // Then
            #expect(error == .timeout)
        }
    }

    @Test
    func withTimeout_whenNonCancellableOperationFailsAfterTimeout_throwsTimeoutError() async {
        // Given
        let operation = { @Sendable () async throws(Failure) in
            try? await Task.sleep(for: .seconds(1))
            throw Failure.generic
        }

        // When
        do throws(Failure) {
            try await withTimeout(0.2, error: Failure.timeout, perform: operation)
            Issue.record("Expected timeout error.")
        } catch {
            // Then
            #expect(error == .timeout)
        }
    }

    @Test
    func withTimeout_whenCancelled_throwsOperationTypedCancellationErrorNotTimeout() async throws {
        // Given
        let task = Task<Result<String, Failure>, Never> {
            do throws(Failure) {
                let value = try await withTimeout(10, error: Failure.timeout) { @Sendable () async throws(Failure) in
                    do {
                        try await Task.sleep(for: .seconds(10))
                    } catch {
                        throw Failure.cancel
                    }
                    return "value"
                }
                return .success(value)
            } catch {
                return .failure(error)
            }
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        task.cancel()

        // Then
        #expect(await task.value == .failure(.cancel))
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
            timeoutError: Failure.timeout as any Error
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
                    try await Task.sleep(for: .seconds(10))
                },
                while: { _ in false },
                timeout: 1,
                timeoutError: Failure.timeout as any Error
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
            timeoutError: Failure.timeout as any Error,
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
            timeoutError: Failure.timeout as any Error,
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
                timeoutError: Failure.timeout as any Error,
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
            timeoutError: Failure.timeout as any Error,
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
            timeoutError: Failure.timeout as any Error,
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
                timeoutError: Failure.timeout as any Error
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

    @Test
    func retry_whenOperationFailsThenSucceeds_returnsSuccessValueAndStopsRetrying() async throws {
        // Given
        let attemptsCount = POUnfairlyLocked<Int>(wrappedValue: 0)
        let observedResults = POUnfairlyLocked<[Result<String, Failure>]>(wrappedValue: [])

        // When
        let value = try await retry(
            operation: { @Sendable () async throws(Failure) -> String in
                let attempt = attemptsCount.withLock { count in
                    count += 1
                    return count
                }
                guard attempt > 1 else {
                    throw Failure.generic
                }
                return "value"
            },
            while: { result in
                observedResults.withLock { $0.append(result) }
                if case .failure(.generic) = result {
                    return true
                }
                return false
            },
            timeout: 10,
            timeoutError: Failure.timeout,
            retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 3, minimum: 0)
        )

        // Then
        #expect(value == "value")
        #expect(observedResults.wrappedValue == [.failure(.generic), .success("value")])
    }

    @Test
    func retry_whenRetriesAreExhaustedOnFailure_throwsLastTypedOperationError() async {
        // Given
        let attemptsCount = POUnfairlyLocked<Int>(wrappedValue: 0)

        // When
        do throws(Failure) {
            _ = try await retry(
                operation: { @Sendable () async throws(Failure) -> String in
                    attemptsCount.withLock { $0 += 1 }
                    throw Failure.generic
                },
                while: { _ in true },
                timeout: 10,
                timeoutError: Failure.timeout,
                retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 2, minimum: 0)
            )
            Issue.record("Expected operation error.")
        } catch {
            // Then
            #expect(error == .generic)
        }
        #expect(attemptsCount.wrappedValue == 3)
    }

    @Test
    func retry_waitsForRetryStrategyDelayBeforeNextAttempt() async throws {
        // Given
        let clock = ContinuousClock()
        let attemptTimes = POUnfairlyLocked<[ContinuousClock.Instant]>(wrappedValue: [])
        let delay: TimeInterval = 0.5

        // When
        _ = try await retry(
            operation: { @Sendable () async throws(Failure) -> String in
                attemptTimes.withLock { $0.append(clock.now) }
                return "value"
            },
            while: { _ in true },
            timeout: 10,
            timeoutError: Failure.timeout,
            // Minimum equal to interval prevents jitter from shortening the delay.
            retryStrategy: .init(function: .linear(interval: delay), maximumRetries: 1, minimum: delay)
        )

        // Then
        let times = attemptTimes.wrappedValue
        try #require(times.count == 2)
        #expect(times[1] - times[0] >= .seconds(delay))
    }

    @Test
    func retry_whenCancelledDuringOperation_throwsTypedCancellationErrorWithoutRetrying() async throws {
        // Given
        let attemptsCount = POUnfairlyLocked<Int>(wrappedValue: 0)
        let task = Task<Result<String, Failure>, Never> {
            do throws(Failure) {
                let value = try await retry(
                    operation: { @Sendable () async throws(Failure) -> String in
                        attemptsCount.withLock { $0 += 1 }
                        do {
                            try await Task.sleep(for: .seconds(10))
                        } catch {
                            throw Failure.cancel
                        }
                        return "value"
                    },
                    while: { _ in true },
                    timeout: 10,
                    timeoutError: Failure.timeout,
                    retryStrategy: .init(function: .linear(interval: 0), maximumRetries: 3, minimum: 0)
                )
                return .success(value)
            } catch {
                return .failure(error)
            }
        }
        try await Task.sleep(for: .milliseconds(100))

        // When
        task.cancel()

        // Then
        #expect(await task.value == .failure(.cancel))
        #expect(attemptsCount.wrappedValue == 1)
    }

    // MARK: - Private Nested Types

    private enum Failure: Error {
        case timeout, generic, cancel
    }
}
