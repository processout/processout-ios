//
//  AsyncUtils.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 08.12.2023.
//

import Foundation

// MARK: - Timeout

/// - Warning: operation should support cancellation, otherwise calling this method has no effect.
func withTimeout<T: Sendable, E: Error>(
    _ timeout: TimeInterval,
    error timeoutError: E,
    perform operation: @escaping @Sendable @isolated(any) () async throws(E) -> T
) async throws(E) -> T {
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
    return try await poWithTaskCancellationHandler { () async throws(E) -> T in
        do {
            let value = try await task.value
            timeoutTask.cancel()
            return value
        } catch {
            if task.isCancelled, isTimedOut.wrappedValue {
                throw timeoutError
            }
            timeoutTask.cancel()
            throw error as! E // swiftlint:disable:this force_cast
        }
    } onCancel: {
        task.cancel()
        timeoutTask.cancel()
    }
}

// MARK: - Retry

func retry<T: Sendable, E: Error>(
    operation: @escaping @Sendable @isolated(any) () async throws(E) -> T,
    while condition: @escaping @Sendable (Result<T, E>) -> Bool,
    timeout: TimeInterval,
    timeoutError: E,
    retryStrategy: RetryStrategy? = nil
) async throws(E) -> T {
    let operationBox = { @Sendable () async throws(E) -> T in
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

private func retry<T: Sendable, E: Error>(
    operation: @escaping @Sendable @isolated(any) () async throws(E) -> T,
    after result: Result<T, E>,
    while condition: @escaping (Result<T, E>) -> Bool,
    retryStrategy: RetryStrategy?,
    attempt: Int
) async throws(E) -> T {
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

// MARK: - Result

extension Result where Success: Sendable {

    init(catching body: () async throws(Failure) -> Success) async {
        do {
            let success = try await body()
            self = .success(success)
        } catch {
            self = .failure(error)
        }
    }
}

// MARK: - Cancellation Handler

/// Execute an operation with a cancellation handler that’s immediately invoked if the current task is canceled.
func poWithTaskCancellationHandler<T, E: Error>(
    operation: () async throws(E) -> T,
    onCancel handler: @Sendable () -> Void,
    isolation: isolated (any Actor)? = #isolation
) async throws(E) -> T {
    do {
        return try await withTaskCancellationHandler(operation: operation, onCancel: handler, isolation: isolation)
    } catch {
        throw error as! E // swiftlint:disable:this force_cast
    }
}

// MARK: - Checked Continuation

/// Invokes the passed in closure with a checked continuation for the current task.
func poWithCheckedContinuation<T, E: Error>(
    isolation: isolated (any Actor)? = #isolation,
    function: String = #function,
    _ body: (CheckedContinuation<T, E>) -> Void
) async throws(E) -> sending T {
    do {
        return try await withCheckedThrowingContinuation(isolation: isolation, function: function) { continuation in
            body(unsafeBitCast(continuation, to: CheckedContinuation<T, E>.self))
        }
    } catch {
        throw error as! E // swiftlint:disable:this force_cast
    }
}
