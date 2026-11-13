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

@_spi(PO)
public func retry<T: Sendable>( // swiftlint:disable:this function_parameter_count
    operation: @escaping @Sendable @isolated(any) () async throws -> T?,
    shouldRetry: @escaping @Sendable (Error) -> Bool,
    timeout: TimeInterval,
    timeoutError: Error,
    cancellationError: Error,
    retryStrategy: RetryStrategy
) async throws -> T {
    try await withTimeout(timeout, error: timeoutError) {
        var attempt = 0
        repeat {
            let lastError: Error
            do {
                if let value = try await operation() {
                    return value
                }
                // Value isn't ready yet. Thrown only if polling stops before it becomes available,
                // i.e. on cancellation or once retries are exhausted. On timeout it is replaced.
                lastError = cancellationError
            } catch where shouldRetry(error) {
                lastError = error
            }
            guard attempt < retryStrategy.maximumRetries, !Task.isCancelled else {
                throw lastError
            }
            do {
                let delay = retryStrategy.interval(for: attempt)
                try await Task.sleep(seconds: delay)
            } catch {
                throw cancellationError
            }
            attempt += 1
        } while true
    }
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
