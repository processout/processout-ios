//
//  Batcher.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2024.
//

import Foundation

final class Batcher<Task>: @unchecked Sendable {

    typealias Executor = @Sendable (Array<Task>) async -> Bool

    init(executionInterval: TimeInterval = 10, executor: @escaping Executor) {
        self.executionInterval = executionInterval
        self.executor = executor
        lock = .init()
        pendingTasks = []
    }

    deinit {
        executionTimer?.invalidate()
    }

    func submit(task: Task) {
        lock.withLock {
            pendingTasks.append(task)
            guard executionTimer == nil else {
                return
            }
            scheduleExecutionUnsafe()
        }
    }

    // MARK: - Private Properties

    private let executor: Executor
    private let executionInterval: TimeInterval
    private let lock: POUnfairlyLocked<Void>

    private var pendingTasks: [Task]
    private var executionTimer: Timer?

    // MARK: - Private Methods

    /// - NOTE: method mutates self but is not thread safe.
    private func scheduleExecutionUnsafe() {
        nonisolated(unsafe) let timer = Timer(timeInterval: executionInterval, repeats: false) { [weak self] _ in
            guard let self = self else {
                return
            }
            _Concurrency.Task {
                await self.executeTasks()
            }
        }
        DispatchQueue.main.async {
            RunLoop.main.add(timer, forMode: .default)
        }
        self.executionTimer = timer
    }

    private func executeTasks() async {
        let tasks = lock.withLock {
            let tasks = self.pendingTasks
            pendingTasks.removeAll()
            return tasks
        }
        let didExecuteTasks = await executor(tasks)
        lock.withLock {
            if !didExecuteTasks {
                self.pendingTasks.insert(contentsOf: tasks, at: 0)
            }
            executionTimer = nil
            guard !pendingTasks.isEmpty else {
                return
            }
            scheduleExecutionUnsafe()
        }
    }
}
