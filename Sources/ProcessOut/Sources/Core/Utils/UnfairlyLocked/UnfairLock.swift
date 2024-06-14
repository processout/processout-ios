//
//  UnfairLock.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 11.04.2024.
//

import os

/// An `os_unfair_lock` wrapper.
final class UnfairLock {

    init() {
        unfairLock = .allocate(capacity: 1)
        unfairLock.initialize(to: os_unfair_lock())
    }

    func withLock<R>(_ body: () -> R) -> R {
        defer {
            os_unfair_lock_unlock(unfairLock)
        }
        os_unfair_lock_lock(unfairLock)
        return body()
    }

    deinit {
        unfairLock.deinitialize(count: 1)
        unfairLock.deallocate()
    }

    // MARK: - Private Properties

    private let unfairLock: os_unfair_lock_t
}
