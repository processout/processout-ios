//
//  Batcher.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 10.04.2024.
//

import Foundation

final class Batcher<Task> {

    typealias Executor = (Array<Task>) async -> Void

    init(executor: @escaping Executor, executionInterval: TimeInterval = 10) {
        self.executor = executor
        self.executionInterval = executionInterval
        pendingTasks = []
    }

    func submit(task: Task) {
        // todo(andrii-vysotskyi): ensure batcher is thread safe
        pendingTasks.append(task)
        guard executionTimer == nil else {
            return
        }
        scheduleExecution()
    }

    // MARK: - Private Properties

    private let executor: Executor
    private let executionInterval: TimeInterval

    private var pendingTasks: [Task]
    private var executionTimer: Timer?

    // MARK: - Private Methods

    private func scheduleExecution() {
        let timer = Timer.scheduledTimer(withTimeInterval: executionInterval, repeats: false) { [weak self] _ in
            guard let self else {
                return
            }
            let tasks = self.pendingTasks
            self.pendingTasks.removeAll()
            _Concurrency.Task {
                await self.executor(tasks)
                self.executionTimer = nil
                guard !self.pendingTasks.isEmpty else {
                    return
                }
                self.scheduleExecution()
            }
        }
        self.executionTimer = timer
    }
}
