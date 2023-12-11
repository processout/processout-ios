//
//  AsyncUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

// MARK: - Async + Completion

/// Invokes given completion with a result of async operation.
func invoke<T>(
    completion: @escaping (Result<T, POFailure>) -> Void,
    after operation: @escaping () async throws -> T
) -> POCancellable {
    Task { @MainActor in
        do {
            let returnValue = try await operation()
            completion(.success(returnValue))
        } catch let failure as POFailure {
            completion(.failure(failure))
        } catch {
            let failure = POFailure(code: .internal(.mobile), underlyingError: error)
            completion(.failure(failure))
        }
    }
}

/// Invokes given completion with a result of async operation.
func invoke<T>(completion: @escaping (T) -> Void, after operation: @escaping () async -> T) -> Task<Void, Never> {
    Task { @MainActor in
        completion(await operation())
    }
}

// MARK: - Timeout

func withTimeout<T: Sendable>(
    _ timeout: TimeInterval,
    operation: @escaping @Sendable () async throws -> T
) async throws -> T {
    let task = Task(operation: operation)
    let timeoutTask = Task {
        try await Task.sleep(nanoseconds: UInt64(timeout) * NSEC_PER_SEC)
        task.cancel()
    }
    let value = try await task.value
    timeoutTask.cancel()
    return value
}

// MARK: - Retry

func retry<T: Sendable>(
    operation: @escaping @Sendable () async throws -> T,
    while condition: @escaping (Result<T, Error>) -> Bool,
    timeout: TimeInterval,
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
    return try await withTimeout(timeout, operation: operationBox)
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
