//
//  AsyncSemaphore.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

import Foundation

@_spi(PO)
public actor AsyncSemaphore {

    // MARK: - Creating a Semaphore

    /// Creates a semaphore.
    public init(value: UInt) {
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
    /// If the resulting count is negative, the current task is suspended without blocking
    /// the thread until the semaphore is signalled. Otherwise, no suspension occurs.
    public func wait() async {
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
    /// If the resulting count is negative, the current task is suspended without blocking
    /// the thread until the semaphore is signalled. Otherwise, no suspension occurs.
    ///
    /// If canceled before signalling, this function throws `CancellationError`.
    public func waitUnlessCancelled() async throws(CancellationError) {
        try await waitUnlessCancelled(cancellationError: CancellationError())
    }

    /// Decrements a semaphore with cancellation support.
    ///
    /// If the resulting count is negative, the current task is suspended without blocking
    /// the thread until the semaphore is signalled. Otherwise, no suspension occurs.
    ///
    /// If canceled before signalling, this function throws `cancellationError`.
    public func waitUnlessCancelled<Failure: Error>(
        cancellationError: @Sendable @escaping @autoclosure () -> Failure
    ) async throws(Failure) {
        guard !Task.isCancelled else {
            throw cancellationError()
        }
        value -= 1
        guard value < 0 else {
            return
        }
        let suspension = AsyncSemaphoreSuspension()
        do {
            try await withTaskCancellationHandler {
                try await withUnsafeThrowingContinuation { continuation in
                    if suspension.setContinuation(continuation, cancellationError: cancellationError) {
                        suspensions.insert(suspension, at: 0)
                    }
                }
            } onCancel: {
                Task {
                    await self.cancel(suspension: suspension)
                }
            }
        } catch let error as Failure {
            throw error
        } catch {
            preconditionFailure("Suspension is expected to be resumed only with the cancellation error.")
        }
    }

    /// Signals the semaphore, incrementing its count.
    ///
    /// Increases the semaphore's count, resuming the longest waiting suspended task
    /// if there is one.
    public nonisolated func signal() {
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

    private func cancel(suspension: AsyncSemaphoreSuspension) {
        if let index = suspensions.firstIndex(where: { $0 === suspension }) {
            // Suspension is still pending, so its slot is given back to the semaphore.
            suspensions.remove(at: index)
            value += 1
        }
        // Cancelling a suspension that was already resumed by a signal is a no-op.
        suspension.cancel()
    }

    private func signalSemaphore() {
        if value >= initialValue {
            assertionFailure("The semaphore value cannot exceed its initial value.")
        }
        value += 1
        if value <= 0 {
            suspensions.popLast()?.resume()
        }
    }
}
