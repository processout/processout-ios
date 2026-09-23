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

    @Test
    func signal_whenWaiterIsSuspended_resumesIt() async {
        // Given
        let sut = AsyncSemaphore(value: 0)
        let task = Task {
            await sut.wait()
        }
        try? await Task.sleep(for: .milliseconds(100))

        // When
        sut.signal()

        // Then
        await task.value
    }

    @Test
    func signal_whenMultipleWaitersAreSuspended_resumesThemInOrder() async throws {
        // Given
        let sut = AsyncSemaphore(value: 0)
        let resumeOrder = POUnfairlyLocked<[Int]>(wrappedValue: [])
        var tasks: [Task<Void, Never>] = []
        for index in 0..<5 {
            tasks.append(
                Task {
                    await sut.wait()
                    resumeOrder.withLock { $0.append(index) }
                }
            )
            // Ensure waiters are suspended in order.
            try await Task.sleep(for: .milliseconds(50))
        }

        // When
        for _ in tasks {
            sut.signal()
            try await Task.sleep(for: .milliseconds(50))
        }
        for task in tasks {
            await task.value
        }

        // Then
        #expect(resumeOrder.wrappedValue == [0, 1, 2, 3, 4])
    }

    @Test
    func signal_whenWaiterIsCancelledConcurrently_doesNotCrash() async throws {
        for _ in 0..<100 {
            // Given
            let sut = AsyncSemaphore(value: 1)
            await sut.wait()
            let waiter = Task {
                try await sut.waitUnlessCancelled()
            }
            try await Task.sleep(for: .milliseconds(1))

            // When holder releases while waiter is being cancelled
            async let release: Void = { sut.signal() }()
            waiter.cancel()
            await release

            // Then waiter either acquires the slot or fails with cancellation.
            if (try? await waiter.value) != nil {
                sut.signal()
            }
            await sut.wait()
        }
    }

    // MARK: - Contention

    @Test(arguments: [1, 3])
    func wait_underContention_neverExceedsValue(value: UInt) async {
        // Given
        let sut = AsyncSemaphore(value: value)
        let active = POUnfairlyLocked<Int>(wrappedValue: 0)
        let maxActive = POUnfairlyLocked<Int>(wrappedValue: 0)
        let priorities: [TaskPriority] = [.background, .utility, .medium, .userInitiated, .high]

        // When
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<1000 {
                group.addTask(priority: priorities[index % priorities.count]) {
                    await sut.wait()
                    let current = active.withLock { count in
                        count += 1
                        return count
                    }
                    maxActive.withLock { $0 = max($0, current) }
                    await Task.yield()
                    active.withLock { $0 -= 1 }
                    sut.signal()
                }
            }
        }

        // Then
        #expect(maxActive.wrappedValue <= Int(value))
        #expect(active.wrappedValue == 0)
    }

    @Test
    func waitUnlessCancelled_underContention_neverExceedsValue() async {
        // Given
        let sut = AsyncSemaphore(value: 1)
        let active = POUnfairlyLocked<Int>(wrappedValue: 0)
        let maxActive = POUnfairlyLocked<Int>(wrappedValue: 0)
        let priorities: [TaskPriority] = [.background, .utility, .medium, .userInitiated, .high]

        // When
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<1000 {
                group.addTask(priority: priorities[index % priorities.count]) {
                    do {
                        try await sut.waitUnlessCancelled()
                    } catch {
                        return
                    }
                    let current = active.withLock { count in
                        count += 1
                        return count
                    }
                    maxActive.withLock { $0 = max($0, current) }
                    await Task.yield()
                    active.withLock { $0 -= 1 }
                    sut.signal()
                }
            }
        }

        // Then
        #expect(maxActive.wrappedValue == 1)
        #expect(active.wrappedValue == 0)
    }

    @Test
    func waitUnlessCancelled_whenSomeWaitersAreCancelled_remainingWaitersStillResume() async throws {
        // Given
        let sut = AsyncSemaphore(value: 0)
        let cancelledTask = Task {
            try await sut.waitUnlessCancelled()
        }
        try await Task.sleep(for: .milliseconds(50))
        let survivingTask = Task {
            try await sut.waitUnlessCancelled()
        }
        try await Task.sleep(for: .milliseconds(50))

        // When
        cancelledTask.cancel()
        _ = try? await cancelledTask.value
        sut.signal()

        // Then
        await #expect(throws: Never.self) {
            try await survivingTask.value
        }
    }

    // MARK: - Private Nested Types

    private struct Failure: Error { }
}
