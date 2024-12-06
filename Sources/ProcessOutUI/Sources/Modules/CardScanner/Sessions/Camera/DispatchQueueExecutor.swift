//
//  DispatchQueueExecutor.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 06.12.2024.
//

import Foundation

final class DispatchQueueExecutor: SerialExecutor {

    init(queue: DispatchQueue) {
        self.queue = queue
    }

    // MARK: - SerialExecutor

    func enqueue(_ job: UnownedJob) {
        queue.async { [self] in
            job.runSynchronously(on: asUnownedSerialExecutor())
        }
    }

    func asUnownedSerialExecutor() -> UnownedSerialExecutor {
        UnownedSerialExecutor(ordinary: self)
    }

    func checkIsolated() {
        dispatchPrecondition(condition: .onQueue(queue))
    }

    // MARK: - Private Properties

    private let queue: DispatchQueue
}
