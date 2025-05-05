//
//  AsyncSemaphoreTests.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.10.2024.
//

import Testing
@testable @_spi(PO) import ProcessOut

struct AsyncSemaphoreTests {

    // MARK: - Wait

    @Test
    func wait_whenInitialValueIsZero_suspends() async throws {
        // Given
        let sut = AsyncSemaphore(value: 0)

        // When
        Task {
            await sut.wait()
            Issue.record("Semaphore is expected to be in waiting state.")
        }
        try await Task.sleep(for: .seconds(1))
    }

    @Test
    func wait_whenInitialValueIsGreaterThanZero_doesntSuspend() async {
        // Given
        let sut = AsyncSemaphore(value: 1)

        // When
        await sut.wait()
    }

    @Test
    func wait_whenSemaphoreIsBlocked_suspendsSecondFunc() async throws {
        // Given
        let sut = AsyncSemaphore(value: 1)

        // When
        await sut.wait()
        Task {
            await sut.wait()
            Issue.record("Semaphore is expected to be in waiting state.")
        }
        try await Task.sleep(for: .seconds(1))
    }

    // MARK: - Wait Unless Cancelled

    @Test
    func waitUnlessCancelled_whenInitialValueIsZero_suspendsAndDoesntThrow() async throws {
        // Given
        let sut = AsyncSemaphore(value: 0)

        // When
        Task {
            await #expect(throws: Never.self) {
                try await sut.waitUnlessCancelled()
                Issue.record("Semaphore is expected to be in waiting state.")
            }
        }
        try await Task.sleep(for: .seconds(1))
    }

    @Test
    func waitUnlessCancelled_whenInitialValueIsGreaterThanZero_doesntSuspendNorThrow() async {
        // Given
        let sut = AsyncSemaphore(value: 1)

        // When
        let task = Task {
            try await sut.waitUnlessCancelled()
        }

        // Then
        await #expect(throws: Never.self) {
            _ = try await task.value
        }
    }

    @Test
    func waitUnlessCancelled_whenSemaphoreIsBlocked_suspendsSecondFuncAndDoesntThrow() async throws {
        // Given
        let sut = AsyncSemaphore(value: 1)

        // When
        try await sut.waitUnlessCancelled()
        Task {
            await #expect(throws: Never.self) {
                try await sut.waitUnlessCancelled()
                Issue.record("Semaphore is expected to be in waiting state.")
            }
        }
        try await Task.sleep(for: .seconds(1))
    }

    @Test
    func waitUnlessCancelled_whenCancelledImmediately_throwsCancellationError() async {
        // Given
        let sut = AsyncSemaphore(value: 0)

        // When
        let task = Task {
            try await sut.waitUnlessCancelled()
        }
        task.cancel()

        // Then
        await #expect(throws: CancellationError.self) {
            _ = try await task.value
        }
    }

    @Test
    func waitUnlessCancelled_whenCancelledAfterDelay_throwsCancellationError() async {
        // Given
        let sut = AsyncSemaphore(value: 0)

        // When
        let task = Task {
            try await sut.waitUnlessCancelled()
        }
        Task {
            try await Task.sleep(for: .seconds(0.5))
            task.cancel()
        }

        // Then
        await #expect(throws: CancellationError.self) {
            _ = try await task.value
        }
    }

    @Test
    func waitUnlessCancelled_whenCancelled_throwsCustomCancellationError() async {
        // Given
        let sut = AsyncSemaphore(value: 0)

        // When
        let task = Task {
            try await sut.waitUnlessCancelled(cancellationError: Failure())
        }
        task.cancel()

        // Then
        await #expect(throws: Failure.self) {
            _ = try await task.value
        }
    }

    // MARK: - Signal

    @Test
    func signal_whenSemaphoreIsBlocked_resumesWhenSignalled() async {
        // Given
        let sut = AsyncSemaphore(value: 1)

        // When
        await sut.wait()
        sut.signal()

        // Then
        await sut.wait()
    }

    // MARK: - Private Nested Types

    private struct Failure: Error { }
}
