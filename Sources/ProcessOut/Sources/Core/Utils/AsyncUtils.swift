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
    error timeoutError: Error,
    perform operation: @escaping @Sendable @isolated(any) () async throws -> T
) async throws -> T {
    let isTimedOut = POUnfairlyLocked(wrappedValue: false)
    let task = Task(operation: operation)
    let timeoutTask = Task {
        try await Task.sleep(seconds: timeout)
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
                throw timeoutError
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
    operation: @escaping @Sendable @isolated(any) () async throws -> T,
    while condition: @escaping @Sendable (Result<T, Error>) -> Bool,
    timeout: TimeInterval,
    timeoutError: Error,
    retryStrategy: RetryStrategy? = nil
) async throws -> T {
    let operationBox = { @Sendable in
        try await retry(
            operation: operation,
            after: await Result(catching: operation),
            while: condition,
            retryStrategy: retryStrategy,
            attempt: 0
        )
    }
    return try await withTimeout(timeout, error: timeoutError, perform: operationBox)
}

private func retry<T: Sendable>(
    operation: @escaping @Sendable @isolated(any) () async throws -> T,
    after result: Result<T, Error>,
    while condition: @escaping (Result<T, Error>) -> Bool,
    retryStrategy: RetryStrategy?,
    attempt: Int
) async throws -> T {
    guard let retryStrategy, attempt < retryStrategy.maximumRetries, !Task.isCancelled, condition(result) else {
        return try result.get()
    }
    do {
        let delay = retryStrategy.interval(for: attempt)
        try await Task.sleep(seconds: delay)
    } catch {
        // Ignored
    }
    return try await retry(
        operation: operation,
        after: await Result(catching: operation),
        while: condition,
        retryStrategy: retryStrategy,
        attempt: attempt + 1
    )
}

extension Result where Failure == Error, Success: Sendable {

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(catching body: () async throws -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
}
