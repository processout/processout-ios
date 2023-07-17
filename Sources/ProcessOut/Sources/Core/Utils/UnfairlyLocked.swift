//
//  UnfairlyLocked.swift
//  ProcessOut
//
//  Created by Andrii Vysotskyi on 14.07.2023.
//

@_implementationOnly import os

/// A thread-safe wrapper around a value.
@propertyWrapper
final class UnfairlyLocked<Value> {

    init(wrappedValue: Value) {
        value = wrappedValue
    }

    /// The contained value. Unsafe for anything more than direct read or write.
    var wrappedValue: Value {
        lock.withLock { value }
    }

    var projectedValue: UnfairlyLocked<Value> {
        self
    }

    func withLock<R>(_ body: (inout Value) -> R) -> R {
        lock.withLock {
            body(&value)
        }
    }

    // MARK: - Private Properties

    private let lock = UnfairLock()
    private var value: Value
}

/// An `os_unfair_lock` wrapper.
private final class UnfairLock {

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
