//
//  AsyncUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

// MARK: - Timeout

/// - Warning: operation should support cancellation, otherwise calling this method has no effect.
func withTimeout<T: Sendable, Failure: Error>(
    _ timeout: TimeInterval,
    error timeoutError: Failure,
    perform operation: @escaping @Sendable @isolated(any) () async throws(Failure) -> T
) async throws(Failure) -> T {
    let task = Task {
        await Result(catching: operation)
    }
    let timeoutTask = Task {
        do {
            try await Task.sleep(seconds: timeout)
        } catch {
            return false // Cancelled before firing.
        }
        task.cancel()
        return true
    }
    let result = await withTaskCancellationHandler {
        await task.value
    } onCancel: {
        task.cancel()
        timeoutTask.cancel()
    }
    timeoutTask.cancel()
    switch result {
    case .success(let value):
        return value
    case .failure(let error):
        throw await timeoutTask.value ? timeoutError : error
    }
}

// MARK: - Retry

/// Retries the given operation while condition is met.
///
/// - Parameters:
///   - operation: operation to retry.
///   - condition: closure that determines whether operation should be retried based on its result.
///   - timeout: maximum amount of time to retry for.
///   - timeoutError: error thrown when timeout is reached.
///   - retryStrategy: strategy that defines delay between retries.
@_spi(PO)
public func retry<T: Sendable, Failure: Error>(
    operation: @escaping @Sendable @isolated(any) () async throws(Failure) -> T,
    while condition: @escaping @Sendable (Result<T, Failure>) -> Bool,
    timeout: TimeInterval,
    timeoutError: Failure,
    retryStrategy: RetryStrategy? = nil
) async throws(Failure) -> T {
    let operationBox = { @Sendable () async throws(Failure) -> T in
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

private func retry<T: Sendable, Failure: Error>(
    operation: @escaping @Sendable @isolated(any) () async throws(Failure) -> T,
    after result: Result<T, Failure>,
    while condition: @escaping (Result<T, Failure>) -> Bool,
    retryStrategy: RetryStrategy?,
    attempt: Int
) async throws(Failure) -> T {
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

extension Result where Success: Sendable {

    // swiftlint:disable:next strict_fileprivate
    fileprivate init(catching body: () async throws(Failure) -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
}
