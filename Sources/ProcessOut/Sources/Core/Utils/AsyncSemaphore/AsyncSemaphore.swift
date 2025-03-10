//
//  AsyncSemaphore.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

import Foundation

actor AsyncSemaphore {

    // MARK: - Creating a Semaphore

    /// Creates a semaphore.
    init(value: UInt) {
        initialValue = Int(value)
        self.value = Int(value)
    }

    deinit {
        let suspensions = self.suspensions
        precondition(
            suspensions.isEmpty, "AsyncSemaphore is deallocated while some task(s) are suspended waiting for a signal."
        )
    }

    // MARK: - Semaphore

    /// Decrements the semaphore.
    ///
    /// If the count is negative, the current task is suspended without blocking
    /// the thread. Otherwise, no suspension occurs.
    func wait() async {
        value -= 1
        guard value < 0 else {
            return
        }
        await withUnsafeContinuation { continuation in
            let suspension = AsyncSemaphoreSuspension()
            if suspension.setContinuation(continuation) {
                suspensions.insert(suspension, at: 0)
            }
        }
    }

    /// Decrements a semaphore with cancellation support.
    ///
    /// If the count is negative, the current task is suspended without blocking
    /// the thread. Otherwise, no suspension occurs.
    ///
    /// If canceled before signalling, this function throws `CancellationError`.
    func waitUnlessCancelled() async throws {
        try Task.checkCancellation()
        value -= 1
        guard value < 0 else {
            return
        }
        let suspension = AsyncSemaphoreSuspension()
        try await withTaskCancellationHandler {
            try await withUnsafeThrowingContinuation { continuation in
                if suspension.setContinuation(continuation) {
                    suspensions.insert(suspension, at: 0)
                }
            }
        } onCancel: {
            Task {
                await self.cancel(suspension: suspension)
            }
        }
    }

    /// Signals the semaphore, incrementing its count.
    ///
    /// Increases the semaphore's count, potentially unblocking a suspended task
    /// if the count transitions from negative to non-negative.
    nonisolated func signal() {
        Task {
            await signalSemaphore()
        }
    }

    // MARK: - Private Properties

    private let initialValue: Int

    /// The semaphore value.
    private var value: Int

    /// As many elements as there are suspended tasks waiting for a signal.
    private var suspensions: [AsyncSemaphoreSuspension] = []

    // MARK: - Private Methods

    private func incrementValue() {
        if value == initialValue {
            assertionFailure("The semaphore value cannot exceed its initial value.")
        }
        value += 1
    }

    // MARK: - Private Methods

    private func cancel(suspension: AsyncSemaphoreSuspension) {
        incrementValue()
        if let index = suspensions.firstIndex(where: { $0 === suspension }) {
            suspensions.remove(at: index)
        }
        suspension.cancel()
    }

    private func signalSemaphore() {
        incrementValue()
        suspensions.popLast()?.resume()
    }
}
