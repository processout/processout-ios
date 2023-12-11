//
//  AsyncUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

// MARK: - Timeout

/// - Warning: operation should support cancellation, otherwise calling this method has no effect.
func withTimeout<T: Sendable>(
    _ timeout: TimeInterval,
    error timeoutError: @autoclosure () -> Error,
    perform operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    let isTimedOut = POUnfairlyLocked(wrappedValue: false)
    let task = Task(operation: operation)
    let timeoutTask = Task {
        try await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
        isTimedOut.withLock { value in
            value = true
        }
        guard !Task.isCancelled else {
            return
        }
        task.cancel()
    }
    return try await withTaskCancellationHandler {
        do {
            let value = try await task.value
            timeoutTask.cancel()
            return value
        } catch {
            if task.isCancelled, isTimedOut.wrappedValue {
                throw timeoutError()
            }
            timeoutTask.cancel()
            throw error
        }
    } onCancel: {
        task.cancel()
        timeoutTask.cancel()
    }
}

// MARK: - Retry

func retry<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T,
    while condition: @escaping (Result<T, Error>) -> Bool,
    timeout: TimeInterval,
    timeoutError: @autoclosure () -> Error,
    retryStrategy: RetryStrategy = .linear(maximumRetries: .max, interval: 3)
) async throws -> T {
    let operationBox = { @Sendable in
        try await retry(
            operation: operation,
            after: await Task(operation: operation).result,
            while: condition,
            retryStrategy: retryStrategy,
            attempt: 0
        )
    }
    return try await withTimeout(timeout, error: timeoutError(), perform: operationBox)
}

private func retry<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T,
    after result: Result<T, Error>,
    while condition: @escaping (Result<T, Error>) -> Bool,
    retryStrategy: RetryStrategy,
    attempt: Int
) async throws -> T {
    guard condition(result), attempt < retryStrategy.maximumRetries, !Task.isCancelled else {
        return try result.get()
    }
    do {
        let delay = retryStrategy.interval(for: attempt)
        try await Task.sleep(nanoseconds: UInt64(delay) * NSEC_PER_SEC)
    } catch {
        return try result.get()
    }
    return try await retry(
        operation: operation,
        after: await Task(operation: operation).result,
        while: condition,
        retryStrategy: retryStrategy,
        attempt: attempt + 1
    )
}
